--L:B Aerys
local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.exctg)
	e1:SetOperation(s.excop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.addlock)
	e3:SetCondition(s.addcon)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return false end
		local g=Duel.GetDecktopGroup(tp,3)
		local result=g:FilterCount(Card.IsAbleToGrave,nil)>0
		return result
	end
	Duel.SetTargetPlayer(tp)
end
function s.tdfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsAbleToGrave()
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.ConfirmDecktop(p,3)
	local g=Duel.GetDecktopGroup(p,3)
	if not g or #g<3 then return end
	g=g:Filter(s.tdfilter,nil)
	local ct=3
	if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)
		local sg=g:Select(p,1,1,nil)
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(sg,nil,REASON_EFFECT)
		ct=ct-1
	end
	Duel.SortDecktop(p,p,ct)
	for i=1,ct do
		local mg=Duel.GetDecktopGroup(p,1)
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
function s.setfilter(c)
	return c:IsSetCard(0xf86) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end
function s.addlock(e,tp,eg,ep,ev,re,r,rp,c)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_TO_HAND)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,1)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetCode(EFFECT_CANNOT_DRAW)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTargetRange(1,1)
		Duel.RegisterEffect(e2,tp)
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==e:GetOwnerPlayer()
end