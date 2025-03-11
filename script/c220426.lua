--Tai
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--link summon
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	c:EnableReviveLimit()
end
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLinkRace(RACE_PSYCHO)
end