-- Divine Arsenal AA-HADES - Death Bringer
local s, id, o = GetID() -- Lấy ID của lá bài.

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id) -- Chỉ cho phép 1 lá bài này trên sân.

    -- Triệu hồi XYZ sử dụng 1-6 quái thú ngửa mặt thuộc archetype 0xd83.
    aux.AddXyzProcedure(c, nil, 12, 6, s.ovfilter, aux.Stringid(id, 0), 0, s.xyzop)
    c:EnableReviveLimit() -- Giới hạn khả năng hồi sinh.

    -- Giới hạn triệu hồi đặc biệt
    local e0 = Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE) -- Không thể vô hiệu hóa hoặc sao chép.
    e0:SetType(EFFECT_TYPE_SINGLE) -- Hiệu ứng đơn.
    e0:SetCode(EFFECT_SPSUMMON_CONDITION) -- Điều kiện triệu hồi đặc biệt.
    e0:SetValue(aux.xyzlimit) -- Giá trị giới hạn triệu hồi XYZ (sử dụng hàm aux.xyzlimit).
    c:RegisterEffect(e0)

    -- Hiệu ứng 1: Nhận hiệu ứng của quái thú XYZ làm nguyên liệu
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS) -- Kích hoạt khi triệu hồi đặc biệt thành công.
    e1:SetOperation(s.gainop)
    c:RegisterEffect(e1)
end

-- Lọc quái thú ngửa mặt thuộc archetype 0xd83
function s.ovfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xd83)
end

-- Hàm thao tác XYZ
function s.xyzop(e, tp, chk)
    -- Thêm logic xử lý việc gắn nguyên liệu XYZ tại đây
    if chk == 0 then
        return Duel.GetMatchingGroup(s.ovfilter, tp, LOCATION_ONFIELD, 0, 1, nil):GetCount() >= 1
    end
    local g = Duel.GetMatchingGroup(s.ovfilter, tp, LOCATION_ONFIELD, 0, 6, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local sg = g:Select(tp, 1, 6, nil)
    Duel.Overlay(e:GetHandler(), sg)
end

-- Hàm thao tác nhận hiệu ứng
function s.gainop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup() -- Lấy nhóm nguyên liệu XYZ.
    local tc = g:GetFirst()
    while tc do
        if tc:IsType(TYPE_XYZ) then -- Kiểm tra nếu nguyên liệu là quái thú XYZ.
            local te = tc:GetActivateEffect() -- Lấy hiệu ứng kích hoạt của nguyên liệu.
            if te then
                local te1 = te:Clone()
                te1:SetType(EFFECT_TYPE_SINGLE) -- Chỉ áp dụng cho lá bài này.
                te1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
                c:RegisterEffect(te1) -- Gắn hiệu ứng cho lá bài.
            end
        end
        tc = g:GetNext()
    end
end