-- Divine Arsenal AA-HADES - Death Bringer
local s, id, o = GetID() -- Lấy ID của lá bài.

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id) -- Chỉ cho phép 1 lá bài này trên sân.
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),6) -- Gắn điều kiện link summon.
end