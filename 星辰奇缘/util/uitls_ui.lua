-- --------------------------------
-- UI工具类
-- --------------------------------
UIUtils = UIUtils or BaseClass()

-- ---------------------------------
-- 添加子对象到父容器，并做基础设置
-- ---------------------------------
function UIUtils.AddUIChild(parentObj, childObj, nopixelperfect)
    local trans = childObj.transform
    trans:SetParent(parentObj.transform)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3.zero
    trans.localRotation = Quaternion.identity

    local rect = childObj:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero
    rect.localScale = Vector3.one
    rect.localPosition = Vector3.zero
    childObj:SetActive(true)

    local canvas = childObj:GetComponent(Canvas)
    if canvas ~= nil then
        -- if nopixelperfect then
            canvas.pixelPerfect = false;
        -- else
        --     canvas.pixelPerfect = true;
        -- end
        canvas.overrideSorting = false;
    end
end

function UIUtils.AddBigbg(parentTransform, childObj)
    local childTransform = childObj.transform
    childTransform:SetParent(parentTransform)
    childTransform.localScale = Vector3.one
    childTransform.localPosition = Vector3.zero
    -- local rect = childObj:GetComponent(RectTransform)
    childTransform.anchoredPosition = Vector2.zero
end