
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST))
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.xyztg)
	e3:SetCost(s.xyzcost)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetHintTiming(TIMING_END_PHASE)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0 end
	Duel.SendtoGrave(c,nil,REASON_COST)
end
function s.filter(c)
	return c:IsCanOverlay() and c:IsFaceup()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzfilter2(c,mg)
	return c:IsType(TYPE_XYZ) and mg:CheckSubGroup(s.gselect,1,#mg,c)
end
function s.gselect(sg,c)
	return sg:IsExists(Card.IsSetCard,1,nil,0x146) and c:IsXyzSummonable(sg,#sg,#sg)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local exg=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if exg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=exg:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		Duel.XyzSummon(tp,tg:GetFirst(),nil,1,nil)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END
end
function s.tdfilter(c)
	return c:IsSetCard(0x146) and c:IsAbleToDeck()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if rg:GetCount()<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=rg:Select(tp,2,2,nil)
	if sg:GetCount()>0 then
		Duel.HintSelection(sg)
		local c=e:GetHandler()
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0
			and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
			Duel.SSet(tp,c)
		end
	end
end

