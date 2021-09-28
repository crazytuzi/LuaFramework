GuideTools = { };

GuideTools.Pos = {
    CUSTOM = 0;

    UP = 1;
    DOWN = 2;
    LEFT = 3;
    RIGHT = 4;

    TOP_LEFT = 10;
    TOP_RIGHT = 12;
    BOTTOM_LEFT = 40;
    BOTTOM_RIGHT = 42;
}

GuideTools.Pivot = {
    TopLeft = 0;
    Top = 1;
    TopRight = 2;
    Left = 3;
    Center = 4;
    Right = 5;
    BottomLeft = 6;
    Bottom = 7;
    BottomRight = 8;
}

function GuideTools.GetChildByIndex(parent, idx)
    if idx <= parent.childCount then
        return parent:GetChild(idx - 1);
    end
    return nil;
end

function GuideTools.GetMonsInScene(monId, owner)
    local roles = GameSceneManager.map:GetAllRoles(ControllerType.MONSTER);
    if roles then
        for i, v in pairs(roles) do
            if (v and v.info and v.info.kind == monId) then
                if owner == nil or value.info.owner == owner then
                    return v;
                end
            end
        end
    end
    return nil;
end

--[[
给对象添加设置引导特效和文本显示
    trs:目标Transform
    eff:特效名
    msg:显示文本
    posType:位置 -GuideTools.Pos
    offset:偏移
--]]
function GuideTools.AddEffectAndTitleToGameObject(trs, eff, msg, posType, offset, depth)
    local d = depth or 1;

    -- local widget = UIUtil.GetComponent(trs.gameObject, "UIWidget");
    local effect = nil;
    if trs then
        if eff then
            effect = UIUtil.GetUIEffect(eff, trs, nil, d);
        else
            effect = GameObject.New("effect");
            UIUtil.AddChild(trs, effect.transform);
        end
        
    else
        error("can't find the effect parent!");
    end
    if effect then
        --UIUtil.AddEffectAnchor(effect, d);
        local ctrl = GuideDisplayCtrl.New(effect.transform, { msg = msg, posType = posType, offset = offset });
        NGUITools.SetLayer(effect, trs.gameObject.layer);
        return ctrl;
    else
        return nil;
    end
end

--[[
设置引导文本显示
trsMsg:Transform
d参数
    msg: 文本
    posType:位置 -GuideTools.Pos
    offset:偏移
    pos:锚点位置.
]]

local _headPosRight = Vector3.New(122, 10, 0);
local _headPosLeft = Vector3.New(-122, 10, 0);

local _quatRight = Quaternion.Euler(0, 0, 0);
local _quatLeft = Quaternion.Euler(0, 180, 0);

function GuideTools.SetMsgFrameDisplay(trsMsg, d)
    local _bg = UIUtil.GetChildByName(trsMsg, "UISprite", "bg");
    local _icoDir = UIUtil.GetChildByName(trsMsg, "UISprite", "icoDir");
    local _txtMsg = UIUtil.GetChildByName(trsMsg, "UILabel", "txt");
    local _icoHead = UIUtil.GetChildByName(trsMsg, "UISprite", "icoHead");

    local offset = d.offset or Vector3.zero;
    if d.msg ~= nil and d.msg ~= "" then
        trsMsg.gameObject:SetActive(true);
        if d.pos then
            Util.SetPos(trsMsg, d.pos)
            --            trsMsg.position = d.pos;
        end
        local dirPos = _icoDir.transform.localPosition;
        local dirRotate = nil;
        local localOffset = Vector3.zero;
        local pivot = nil;
        local headPos = nil;
        local txtPos = nil;

        if d.posType == GuideTools.Pos.CUSTOM then
            localOffset = offset;

        elseif d.posType == GuideTools.Pos.UP then
            dirRotate = -90;
            dirPos = Vector3.New(0, -40.5, 0);
            localOffset = Vector3.New(0, 57, 0) + offset;
            pivot = UIWidget.Pivot.IntToEnum(GuideTools.Pivot.Left);
            headPos = _headPosRight;
            txtPos = Vector3.New(-45, -4, 0);
            _icoHead.transform.localRotation = _quatLeft;

        elseif d.posType == GuideTools.Pos.DOWN then
            dirRotate = 90;
            dirPos = Vector3.New(0, 40.5, 0);
            localOffset = Vector3.New(0, -57, 0) + offset;
            pivot = UIWidget.Pivot.IntToEnum(GuideTools.Pivot.Left);
            headPos = _headPosRight;
            txtPos = Vector3.New(-45, -4, 0);
            _icoHead.transform.localRotation = _quatLeft;

        elseif d.posType == GuideTools.Pos.LEFT then
            dirRotate = 0;
            dirPos = Vector3.New(175, 0, 0);
            pivot = UIWidget.Pivot.IntToEnum(GuideTools.Pivot.Right);
            localOffset = Vector3.New(-175, 0, 0) + offset;
            headPos = _headPosLeft;
            txtPos = Vector3.New(45, -4, 0);
            _icoHead.transform.localRotation = _quatRight;

        elseif d.posType == GuideTools.Pos.RIGHT then
            dirRotate = 180
            dirPos = Vector3.New(-175, 0, 0);
            pivot = UIWidget.Pivot.IntToEnum(GuideTools.Pivot.Left);
            localOffset = Vector3.New(175, 0, 0) + offset;
            headPos = _headPosRight;
            txtPos = Vector3.New(-45, -4, 0);
            _icoHead.transform.localRotation = _quatLeft;

        elseif d.posType == GuideTools.Pos.TOP_LEFT then
            dirRotate = -90;
            dirPos = Vector3.New(130, -40.5, 0);
            pivot = UIWidget.Pivot.IntToEnum(GuideTools.Pivot.Right);
            localOffset = Vector3.New(-130, 57, 0) + offset;
            headPos = _headPosLeft;
            txtPos = Vector3.New(45, -4, 0);
            _icoHead.transform.localRotation = _quatRight;

        elseif d.posType == GuideTools.Pos.TOP_RIGHT then
            dirRotate = -90;
            dirPos = Vector3.New(-130, -40.5, 0);
            pivot = UIWidget.Pivot.IntToEnum(GuideTools.Pivot.Left);
            localOffset = Vector3.New(130, 57, 0) + offset;
            headPos = _headPosRight;
            txtPos = Vector3.New(-45, -4, 0);
            _icoHead.transform.localRotation = _quatLeft;

        elseif d.posType == GuideTools.Pos.BOTTOM_LEFT then
            dirRotate = 90;
            dirPos = Vector3.New(130, 40.5, 0);
            pivot = UIWidget.Pivot.IntToEnum(GuideTools.Pivot.Right);
            localOffset = Vector3.New(-130, -57, 0) + offset;
            headPos = _headPosLeft;
            txtPos = Vector3.New(45, -4, 0);
            _icoHead.transform.localRotation = _quatRight;

        elseif d.posType == GuideTools.Pos.BOTTOM_RIGHT then
            dirRotate = 90;
            dirPos = Vector3.New(-130, 40.5, 0);
            pivot = UIWidget.Pivot.IntToEnum(GuideTools.Pivot.Left);
            localOffset = Vector3.New(130, -57, 0) + offset;
            headPos = _headPosRight;
            txtPos = Vector3.New(-45, -4, 0);
            _icoHead.transform.localRotation = _quatLeft;

        end

        _txtMsg.text = d.msg;

        if d.pos then
            Util.SetLocalPos(trsMsg, trsMsg.localPosition + localOffset)

            --            trsMsg.localPosition = trsMsg.localPosition + localOffset;
        else
            Util.SetLocalPos(trsMsg, localOffset.x, localOffset.y, localOffset.z)

            --            trsMsg.localPosition = localOffset;
        end

        if pivot then
            _bg.pivot = pivot;
        end

        if headPos then
            Util.SetLocalPos(_icoHead, headPos.x, headPos.y, headPos.z)
            --            _icoHead.transform.localPosition = headPos;
        end

        if txtPos then
            Util.SetLocalPos(_txtMsg, txtPos.x, txtPos.y, txtPos.z)
            --            _txtMsg.transform.localPosition = txtPos;
        end

        Util.SetLocalPos(_icoDir, dirPos.x, dirPos.y, dirPos.z)

        --        _icoDir.transform.localPosition = dirPos;
        if dirRotate then
            _icoDir.transform.localRotation = Quaternion.Euler(0, 0, dirRotate);
        end

    else
        trsMsg.gameObject:SetActive(false);
    end
end
