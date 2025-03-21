-- Divine Arsenal Y-1
local s, id, o = GetID() -- Lấy ID của lá bài.

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id) -- Chỉ cho phép 1 lá bài này trên sân.

    -- Triệu hồi XYZ
    aux.AddXyzProcedure(c, nil, 12, 1, nil, nil, 99) -- Sử dụng 1+ quái thú Level 12 để triệu hồi XYZ.
    c:EnableReviveLimit() -- Giới hạn khả năng hồi sinh.
    aux.EnablePendulumAttribute(c,false) -- Cho phép triệu hồi Pendulum.

    -- Hiệu ứng 0: Triệu hồi đặc biệt từ Zone Pendulum
    local e0 = Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id, 1))
    e0:SetType(EFFECT_TYPE_IGNITION)
    e0:SetRange(LOCATION_PZONE)
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e0:SetCountLimit(1, id)
    e0:SetTarget(s.sptg)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)

    -- Hiệu ứng 1: Triệu hồi đặc biệt từ Extra Deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0)) -- Mô tả hiệu ứng.
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCountLimit(1, id + EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Hiệu ứng 2: Trả quái thú triệu hồi của đối thủ về tay khi triệu hồi thành công
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1)) -- Mô tả hiệu ứng.
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F) -- Hiệu ứng bắt buộc.
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.rthcon) -- Điều kiện: Quái thú triệu hồi thuộc về đối thủ.
    e2:SetTarget(s.rthtg) -- Mục tiêu: Trả quái thú đối thủ về tay.
    e2:SetOperation(s.rthop) -- Hành động: Thực hiện trả quái thú về tay.
    c:RegisterEffect(e2)

    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS) -- Kích hoạt khi triệu hồi đặc biệt thành công.
    c:RegisterEffect(e3)

    -- Hiệu ứng 3: Giới hạn triệu hồi đặc biệt (chỉ cho phép quái thú tộc Máy)
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(1, 0)
    e4:SetTarget(s.splimit)
    c:RegisterEffect(e4)
end

-- Lọc quái thú Pendulum có thể triệu hồi đặc biệt
function s.sptgfilter(c)
    return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

-- Mục tiêu của hiệu ứng triệu hồi đặc biệt từ Zone Pendulum
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE + LOCATION_GRAVE) and s.sptgfilter(chkc)
    end
    local c = e:GetHandler()
    local tc = Duel.GetFirstMatchingCard(nil, tp, LOCATION_PZONE, 0, c)
    if chk == 0 then
        return tc and Duel.GetMZoneCount(tp) > 0 and tc:IsCanBeSpecialSummoned(e, 0, tp, false, false)
            and Duel.IsExistingTarget(s.sptgfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 4))
    local g = Duel.SelectTarget(tp, s.sptgfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, tc, 1, 0, 0)
    if g:GetFirst():IsLocation(LOCATION_GRAVE) then
        Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
    end
end

-- Hành động của hiệu ứng triệu hồi đặc biệt từ Zone Pendulum
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstMatchingCard(nil, tp, LOCATION_PZONE, 0, c)
    local fc = Duel.GetFirstTarget()
    if tc and Duel.GetMZoneCount(tp) > 0
        and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0
        and fc:IsRelateToEffect(e) then
        Duel.MoveToField(fc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end
end

-- Điều kiện triệu hồi đặc biệt từ Extra Deck
function s.filter(c)
    return c:IsCode(220448) and c:IsFaceup() -- Kiểm tra lá bài có ID 220448 (siêu cấp conti).
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_ONFIELD, 0, 1, nil) -- Kiểm tra có lá bài siêu cấp conti trên sân.
end

-- Điều kiện: Quái thú triệu hồi thuộc về đối thủ
function s.rthcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(Card.IsControler, 1, nil, 1 - tp) -- Kiểm tra nếu quái thú thuộc về đối thủ.
end

-- Mục tiêu: Trả quái thú đối thủ về tay
function s.rthtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return eg:IsExists(Card.IsAbleToHand, 1, nil) end -- Kiểm tra nếu có quái thú có thể trả về tay.
    Duel.SetTargetCard(eg) -- Đặt mục tiêu là các quái thú vừa được triệu hồi.
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, eg, #eg, 0, 0)
end

-- Hành động: Trả quái thú đối thủ về tay
function s.rthop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(Card.IsRelateToEffect, nil, e) -- Lọc các quái thú liên quan đến hiệu ứng.
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT) -- Trả các quái thú đó về tay.
    end
end

-- Giới hạn triệu hồi đặc biệt (chỉ quái thú tộc Máy)
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return not c:IsRace(RACE_MACHINE)
end