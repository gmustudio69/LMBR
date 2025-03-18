-- Divine Arsenal L-5
local s,id,o=GetID() -- Lấy ID của lá bài.

function s.initial_effect(c)
	-- Hiệu ứng triệu hồi Xyz
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)) -- Mô tả hiệu ứng
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON) -- Loại hiệu ứng: Triệu hồi đặc biệt
	e1:SetType(EFFECT_TYPE_QUICK_O) -- Hiệu ứng kích hoạt nhanh
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET) -- Hiệu ứng có mục tiêu
	e1:SetRange(LOCATION_HAND) -- Kích hoạt từ tay
	e1:SetCode(EVENT_FREE_CHAIN) -- Kích hoạt bất kỳ lúc nào
	e1:SetCountLimit(1,id) -- Giới hạn số lần kích hoạt mỗi lượt
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END) -- Gợi ý thời điểm kích hoạt
	e1:SetCondition(s.xyzcon) -- Điều kiện kích hoạt
	e1:SetTarget(s.xyztg) -- Mục tiêu của hiệu ứng
	e1:SetOperation(s.xyzop) -- Thực hiện hiệu ứng
	c:RegisterEffect(e1)

	-- Hiệu ứng thêm lá bài từ mộ vào tay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1)) -- Mô tả hiệu ứng
	e2:SetCategory(CATEGORY_TOHAND) -- Loại hiệu ứng: Thêm vào tay
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) -- Hiệu ứng kích hoạt khi có điều kiện
	e2:SetCode(EVENT_PHASE+PHASE_END) -- Kích hoạt vào cuối lượt
	e2:SetRange(LOCATION_GRAVE) -- Kích hoạt từ mộ
	e2:SetCountLimit(1,id+o*1) -- Giới hạn số lần kích hoạt mỗi lượt
	e2:SetCondition(s.thcon) -- Điều kiện kích hoạt
	e2:SetTarget(s.thtg) -- Mục tiêu của hiệu ứng
	e2:SetOperation(s.thop) -- Thực hiện hiệu ứng
	c:RegisterEffect(e2)

	-- Kiểm tra toàn cục (global check) để theo dõi các lá bài được thêm vào tay
	if not s.global_check then
		s.global_check=true
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) -- Hiệu ứng liên tục
		e0:SetCode(EVENT_TO_HAND) -- Kích hoạt khi lá bài được thêm vào tay
		e0:SetOperation(s.regop) -- Thực hiện hiệu ứng
		Duel.RegisterEffect(e0,0) -- Đăng ký hiệu ứng
	end
end

-- Điều kiện để kích hoạt hiệu ứng triệu hồi Xyz
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase() -- Lấy giai đoạn hiện tại
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2 -- Chỉ kích hoạt trong giai đoạn chính (cả lượt mình và lượt đối thủ)
end

-- Bộ lọc để tìm các lá bài phù hợp cho triệu hồi Xyz
function s.xyzfilter(c,tp,mc)
	local mg=Group.FromCards(c,mc) -- Tạo nhóm gồm lá bài mục tiêu và lá bài hiện tại
	return c:IsFaceup() and Duel.IsExistingMatchingCard(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil,mg) -- Kiểm tra xem có thể triệu hồi Xyz không
end

-- Xác định mục tiêu cho hiệu ứng triệu hồi Xyz
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler() -- Lấy lá bài hiện tại
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc,tp,c) end -- Kiểm tra mục tiêu hợp lệ
	if chk==0 then
		return Duel.IsPlayerCanSpecialSummonCount(tp,2) -- Kiểm tra xem người chơi có thể triệu hồi đặc biệt 2 lần không
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 -- Kiểm tra ô trống trên sân
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) -- Kiểm tra xem lá bài có thể triệu hồi đặc biệt không
			and Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) -- Kiểm tra mục tiêu hợp lệ
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP) -- Gợi ý chọn mục tiêu
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c) -- Chọn mục tiêu
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND) -- Đặt thông tin hiệu ứng
end

-- Thực hiện hiệu ứng triệu hồi Xyz
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() -- Lấy lá bài hiện tại
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end -- Kiểm tra nếu không thể triệu hồi đặc biệt
	local tc=Duel.GetFirstTarget() -- Lấy mục tiêu đầu tiên
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsControler(tp) then return end -- Kiểm tra mục tiêu hợp lệ
	Duel.AdjustAll() -- Điều chỉnh trạng thái trên sân
	local mg=Group.FromCards(c,tc) -- Tạo nhóm lá bài để triệu hồi Xyz
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end -- Kiểm tra số lượng lá bài trên sân
	local g=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,mg) -- Tìm các lá bài có thể triệu hồi Xyz
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON) -- Gợi ý chọn lá bài
		local sg=g:Select(tp,1,1,nil) -- Chọn lá bài để triệu hồi
		Duel.XyzSummon(tp,sg:GetFirst(),mg) -- Triệu hồi Xyz
	end
end

-- Đăng ký hiệu ứng khi lá bài được thêm vào tay
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(s.cfilter,1,nil,p) then -- Kiểm tra nếu có lá bài được thêm vào tay
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1) -- Đăng ký cờ hiệu
		end
	end
end

-- Điều kiện để thêm lá bài từ mộ vào tay
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) -- Kiểm tra nếu có lá bài phù hợp trên sân
end

-- Bộ lọc để tìm lá bài phù hợp để thêm vào tay
function s.thfilter(c)
	return c:IsSetCard(0xd83) and c:IsType(TYPE_MONSTER) and c:IsFaceup() -- Kiểm tra lá bài thuộc bộ bài và là quái vật ngửa
end

-- Xác định mục tiêu để thêm vào tay
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler() -- Lấy lá bài hiện tại
	if chk==0 then return c:IsAbleToHand() end -- Kiểm tra nếu lá bài có thể thêm vào tay
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription()) -- Hiển thị mô tả hiệu ứng
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0) -- Đặt thông tin hiệu ứng
end

-- Thực hiện hiệu ứng thêm lá bài từ mộ vào tay
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() -- Lấy lá bài hiện tại
	if c:IsRelateToEffect(e) then -- Kiểm tra nếu lá bài liên quan đến hiệu ứng
		Duel.SendtoHand(c,nil,REASON_EFFECT) -- Thêm lá bài vào tay
	end
end