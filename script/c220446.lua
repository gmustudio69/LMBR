--Divine Arsenal D-6
local s,id,o=GetID() -- Lấy ID của lá bài.

function s.initial_effect(c)
	-- Special summon từ tay hoặc mộ
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(bit.bor(LOCATION_HAND,LOCATION_GRAVE)) -- Sử dụng bit.bor để kết hợp vị trí.
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	-- Special summon từ bộ bài
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(bit.bor(EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS))
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

-- Hàm lọc: kiểm tra lá bài thuộc bộ bài 0xd83 và đang ngửa mặt.
function s.filter(c)
	return c:IsSetCard(0xd83) and c:IsFaceup()
end

-- Điều kiện triệu hồi đặc biệt
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 -- Không có quái thú trên sân.
		or (Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) -- Có ít nhất 1 quái thú thuộc bộ bài 0xd83.
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) -- Có ô trống trên sân.
end

-- Hàm lọc: kiểm tra lá bài hệ đất, tộc máy móc và có thể triệu hồi đặc biệt.
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Mục tiêu cho hiệu ứng triệu hồi đặc biệt từ bộ bài
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 -- Kiểm tra có ô trống trên sân.
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) -- Có ít nhất 1 lá bài phù hợp trong bộ bài.
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- Hành động khi hiệu ứng được kích hoạt
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end -- Kiểm tra nếu không còn ô trống trên sân.
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp) -- Người chơi chọn 1 lá bài phù hợp từ bộ bài.
	if #g>0 then -- Kiểm tra nếu có lá bài được chọn.
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) -- Triệu hồi đặc biệt lá bài đó.

		-- Thêm hạn chế triệu hồi đặc biệt (chỉ cho phép triệu hồi quái thú Machine)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

-- Hạn chế triệu hồi đặc biệt (chỉ cho phép triệu hồi quái thú Machine)
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_MACHINE) -- Chỉ cho phép triệu hồi quái thú Machine.
end