require "Core.Module.Common.UIComponent"

JoystickPanel = class("JoystickPanel", UIComponent)
 
function JoystickPanel:New()
    self = { };
    setmetatable(self, { __index = JoystickPanel });
    self._enable = true;
    return self;
end  

function JoystickPanel:_InitListenerkeyboard()
    self._listenerKeyboardTimer = Timer.New( function(val) self:_OnListenerKeyboardTimer(val) end, 0, -1, false);
    self._listenerKeyboardTimer:Start()
    self._isDown_W = false;
    self._isDown_D = false;
    self._isDown_S = false;
    self._isDown_A = false;
end

function JoystickPanel:_OnListenerKeyboardTimer()
    local hero = HeroController.GetInstance();
    if (hero and hero.transform and(not hero:IsAutoFight() or(hero:IsAutoFight() and hero:IsPauseAutoFight())) and(not hero:IsDie()) and hero.state ~= RoleState.STILL and hero.state ~= RoleState.STUN) then
        local action = hero:GetAction();
        if (action == nil or(action ~= nil and(action.actionType ~= ActionType.BLOCK or action.canMove))) then
            local blDownW = Input.GetKey(KeyCode.W);
            local blDownD = Input.GetKey(KeyCode.D);
            local blDownS = Input.GetKey(KeyCode.S);
            local blDownA = Input.GetKey(KeyCode.A);
            if (self._isDown_W ~= blDownW or self._isDown_D ~= blDownD or self._isDown_S ~= blDownS or self._isDown_A ~= blDownA) then
                self._isDown_W = blDownW;
                self._isDown_D = blDownD;
                self._isDown_S = blDownS;
                self._isDown_A = blDownA;
                if (self._isDown_W or self._isDown_D or self._isDown_S or self._isDown_A) then
                    if ((self._isDown_W and self._isDown_S) or(self._isDown_A and self._isDown_D)) then
                        hero:Stand();
                    else
                        if (self._isDown_W) then
                            if (self._isDown_D) then
                                hero:MoveToAngle(315);
                            elseif (self._isDown_A) then
                                hero:MoveToAngle(225);
                            else
                                hero:MoveToAngle(270);
                            end
                        elseif (self._isDown_D) then
                            if (self._isDown_W) then
                                hero:MoveToAngle(-45);
                            elseif (self._isDown_S) then
                                hero:MoveToAngle(45);
                            else
                                hero:MoveToAngle(0);
                            end
                        elseif (self._isDown_S) then
                            if (self._isDown_D) then
                                hero:MoveToAngle(45);
                            elseif (self._isDown_A) then
                                hero:MoveToAngle(135);
                            else
                                hero:MoveToAngle(90);
                            end
                        elseif (self._isDown_A) then
                            if (self._isDown_S) then
                                hero:MoveToAngle(135);
                            elseif (self._isDown_W) then
                                hero:MoveToAngle(225);
                            else
                                hero:MoveToAngle(180);
                            end
                        end
                    end
                else
                    hero:Stand();
                end
            end
        end
    end
end

function JoystickPanel:_Init()
    self.radius = 150
    self._enable = true
    local imgs = UIUtil.GetComponentsInChildren(self._transform, "UISprite");
    self._imgJoystickBg = UIUtil.GetChildInComponents(imgs, "imgJoystickBg");
    self._imgJoystick = UIUtil.GetChildInComponents(imgs, "imgJoystick");
    self._imgPoint = UIUtil.GetChildInComponents(imgs, "imgPoint");
    self.imgPointTip = UIUtil.GetChildInComponents(imgs, "imgPointTip");

    self._onPress_spJoystick = function(go, isPress) self:_OnPress_spJoystick(isPress) end
    UIUtil.GetComponent(self._imgJoystick, "LuaUIEventListener"):RegisterDelegate("OnPress", self._onPress_spJoystick);

    self._OnDrag_spJoystick = function(go, pos) self:_OnDragSpJoystick(pos) end
    UIUtil.GetComponent(self._imgJoystick, "LuaUIEventListener"):RegisterDelegate("OnDrag", self._OnDrag_spJoystick);


    self.view_w = GameConfig.instance.uiSize.y * Screen.width / Screen.height
    self.view_h = GameConfig.instance.uiSize.y

    

    self.canDrag = false
    self._mousePos = Vector3.zero

    self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
    self._timer:Start();

    Util.SetLocalPos(self._imgPoint, self:_GetTfPostion(0, 0))
    -- self._imgPoint.transform.localPosition = self:_GetTfPostion(0, 0);
    self._originPos = self._imgPoint.transform.localPosition;
    self._targetPos = self._imgPoint.transform.localPosition;
    self:_OnPress_spJoystick(false);


    self:SetTipV(true);
    -- self:_InitListenerkeyboard();
end

function JoystickPanel:SetTipV(v)
    self.imgPointTip.gameObject:SetActive(v);
    if v then
        self._imgPoint.gameObject:SetActive(false);
        self._imgJoystickBg.gameObject:SetActive(false);
    else
        self._imgPoint.gameObject:SetActive(true);
        self._imgJoystickBg.gameObject:SetActive(true);
    end

end

function JoystickPanel:StopDrag()
    self:_OnPress_spJoystick(false);
end

function JoystickPanel:_Dispose()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    if (self._listenerKeyboardTimer) then
        self._listenerKeyboardTimer:Stop()
        self._listenerKeyboardTimer = nil;
    end
    UIUtil.GetComponent(self._imgJoystick, "LuaUIEventListener"):RemoveDelegate("OnPress");
    self._onPress_spJoystick = nil;

    UIUtil.GetComponent(self._imgJoystick, "LuaUIEventListener"):RemoveDelegate("OnDrag");
    self._OnDrag_spJoystick = nil

    self._imgJoystickBg = nil;
    self._imgJoystick = nil;
    self._imgPoint = nil;
    self.imgPointTip = nil;
end

function JoystickPanel:_OnTimerHandler()
    if (self.canDrag and self._angle) then
        local hero = HeroController.GetInstance();
        if (hero and hero.transform and(not hero:IsAutoFight() or(hero:IsAutoFight() and hero:IsPauseAutoFight())) and(not hero:IsDie()) and hero.state ~= RoleState.STILL and hero.state ~= RoleState.STUN) then
            local action = hero:GetAction();
            if (action == nil or(action ~= nil and(action.actionType ~= ActionType.BLOCK or action.canMove))) then
                local flg = self._pastAngle ~= self._angle
                if not flg and self.cameraLensRotation ~= cameraLensRotation then
                    self.cameraLensRotation = cameraLensRotation
                    flg = true
                end
                if flg then
                    hero:MoveToAngle(self._angle);
                    SequenceManager.TriggerEvent(SequenceEventType.Base.MANUALLY_MOVE);
                    self._pastAngle = self._angle;
                end
            else
                self._pastAngle = nil;
            end
        else
            self._pastAngle = nil;
        end
    end
end

function JoystickPanel:_OnDragSpJoystick(pos)
    --    log(pos)
    if (self._enable) then
        if self.canDrag then
            self._targetPos = self._targetPos + Vector3.New(pos.x, pos.y, 0);
            local dis = Vector3.Distance(self._targetPos, self._mousePos);
            if (dis >= self.radius) then
                local vec =(self._targetPos - self._mousePos) *(self.radius / dis)
                vec = self._mousePos + vec
                Util.SetLocalPos(self._imgPoint, vec.x, vec.y, vec.z)
                --                self._imgPoint.transform.localPosition = vec;
            else
                Util.SetLocalPos(self._imgPoint, self._targetPos.x, self._targetPos.y, self._targetPos.z)

                --                self._imgPoint.transform.localPosition = self._targetPos
            end
            if (Vector3.Distance(self._imgPoint.transform.localPosition, self._mousePos) > 20) then
                -- local a = math.atan2(self._mousePos.y - self._targetPos.y, self._targetPos.x - self._mousePos.x) / math.pi * 180.0 + 90 + cameraLensRotation;
                local a = math.atan2(self._mousePos.y - self._targetPos.y, self._targetPos.x - self._mousePos.x) / math.pi * 180.0;
                if (self._angle == nil or math.abs(math.abs(a) - math.abs(self._angle)) > 5) then
                    self._angle = a;
                end
            end
        end
    end
    -- if (_onDragHandler != null)
    -- {
    --     _onDragHandler(a);
    -- }
end

function JoystickPanel:_OnPress_spJoystick(isPressed)
    local hero = PlayerManager.hero;
    if (self._enable) then
        if (self.canDrag ~= isPressed) then

            if (isPressed) then

                BusyLoadingPanel.CheckAndStopLoadingPanel();

                local isFl = HeroController:GetInstance():IsFollowAiCtr();
                if isFl then
                    log("can not to MoveToAngle");
                    MsgUtils.ShowTips(nil, nil, nil, "跟随状态无法执行此操作");
                    return;
                end

                self.cameraLensRotation = cameraLensRotation
                self.canDrag = true;
                self._imgPoint.color = Color.New(1.0, 1.0, 1.0, 1.0);
                local mx = UICamera.currentTouch.pos.x;
                local my = UICamera.currentTouch.pos.y;
                self._mousePos = self:_GetTfPostion(mx, my);
                self._mousePos.z = self._imgPoint.transform.localPosition.z;
                Util.SetLocalPos(self._imgPoint, self._mousePos.x, self._mousePos.y, self._mousePos.z)
                Util.SetLocalPos(self._imgJoystickBg, self._mousePos.x, self._mousePos.y, self._mousePos.z)
                --                self._imgPoint.transform.localPosition = self._mousePos;
                --                self._imgJoystickBg.transform.localPosition = self._mousePos;
                self._targetPos = self._mousePos;
                if (hero:IsAutoFight()) then
                    hero:PauseAutoFight();
                end
                hero:StopAutoKill();
                self:SetTipV(false);
                if (self._timer) then
                    self._timer:Pause(false);
                end

                -- 当操作 摇杆的时候， 就打断了 队长在 宗门历练 的自动 功能
                -- if ZongMenLiLianDataManager.autoFightForZMLL then
                --     ZongMenLiLianProxy.ZongMenLiLianCancelGetNpc()
                --     ZongMenLiLianDataManager.autoFightForZMLL = false;
                -- end

                SequenceManager.TriggerEvent(SequenceEventType.Guide.NOVICE_OPERATION_MOVE_START);
            else
                self._imgPoint.color = Color.New(1.0, 1.0, 1.0, 0.3);
                self._imgJoystickBg.color = Color.New(1.0, 1.0, 1.0, 0.3);

                Util.SetLocalPos(self._imgPoint, self._originPos.x, self._originPos.y, self._originPos.z)
                Util.SetLocalPos(self._imgJoystickBg, self._originPos.x, self._originPos.y, self._originPos.z)
                 
--                self._imgPoint.transform.localPosition = self._originPos;
--                self._imgJoystickBg.transform.localPosition = self._originPos;
                self._targetPos = self._originPos;
                self:SetTipV(true);

                -- if (_onPressHandler != null)
                -- {
                --     _onPressHandler();
                -- }
                if (hero:IsAutoFight()) then
                    hero:ResumeAutoFight();
                end
                hero:Stand();
                self._angle = nil;
                self._pastAngle = nil;
                self.cameraLensRotation = nil
                self.canDrag = false;
                if (self._timer) then
                    self._timer:Pause(true);
                end
                SequenceManager.TriggerEvent(SequenceEventType.Guide.NOVICE_OPERATION_MOVE_END);
            end
        end
    end
end 

function JoystickPanel:_GetTfPostion(x, y)
    local uv_x = x / Screen.width;
    local uv_y = y / Screen.height;

    local re_x = uv_x * self.view_w;
    local re_y = uv_y * self.view_h;

    local rese = Vector3.New(re_x, re_y, 0);
    return rese;
end
 
function JoystickPanel:SetOperateEnable(enable)
    if (not enable) then
        self:_OnPress_spJoystick(false)
    end
    self._enable = enable
end