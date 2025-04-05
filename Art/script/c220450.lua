--Warrior, Charges into Battle!!!
local s,id,o=GetID()
function s.initial_effect(c)
	-- Activation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Cost: Pay 2000 LP
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end

-- Filter for Warrior monsters with same attribute but different names
function s.filter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToGrave() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target function
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
		return g:CheckSubGroup(aux.dncheck,2,2,function(g)
			return g:GetFirst():GetAttribute()==g:GetNext():GetAttribute()
		end)
	end
end

-- Activation: Reveal 2 valid targets, opponent chooses 1 to summon, destroy the other
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=g:SelectSubGroup(tp,function(g)
		return g:GetFirst():GetAttribute()==g:GetNext():GetAttribute()
	end,false,2,2)
	if not sg or #sg~=2 then return end
	Duel.ConfirmCards(1-tp,sg)
	local opg=sg:Select(1-tp,1,1,nil)
	local tc=opg:GetFirst()
	sg:RemoveCard(tc)
	local toDestroy=sg:GetFirst()

	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and toDestroy then
		Duel.Destroy(toDestroy,REASON_EFFECT)
	end
end

