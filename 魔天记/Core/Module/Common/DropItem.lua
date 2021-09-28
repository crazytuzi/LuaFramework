require "Core.Module.Common.ResID"

DropItem = class("DropItem")
DropItem.dropTime = 0.3 -- 物品弹起来的整体时间
DropItem.height = 0.2 -- 物品弹起来的高度
DropItem.duration = 3 -- 物品落下后等待的时间
DropItem.moveToPlayerDuration = 5 -- 物品从地上移动到主角身上的时间
DropItem.speed = 0.3 -- 物品从地上移动到主角身上的速度
DropItem.COIN_ID = 1 -- 金钱的ID
DropItem.RANDON_SEED = 150 -- 随机位置的范围
function DropItem:New(itemId, targetPos, count)
    self = { };
    setmetatable(self, { __index = DropItem });
    self._targetPos = targetPos + Vector3.forward * math.random(- DropItem.RANDON_SEED, DropItem.RANDON_SEED) * 0.01 + Vector3.right * math.random(- DropItem.RANDON_SEED, DropItem.RANDON_SEED) * 0.01
    self._time = 0
    self:Init(itemId, count)

    return self;
end

function DropItem:Init(itemId, count)
    local item = ProductManager.GetProductById(itemId)
    if (item) then
        self.gameObject = UIUtil.GetUIGameObject(ResID.UI_DROPITEM, Scene.instance.uiDropParent)
        self.transform = self.gameObject.transform
        self._tsChild = UIUtil.GetChildByName(self.gameObject, "Transform", "trsChild")
        self._txtItem = UIUtil.GetChildByName(self._tsChild.gameObject, "UILabel", "txtName")
        self._imgItem = UIUtil.GetChildByName(self._tsChild.gameObject, "UISprite", "imgItem")
        if (itemId == DropItem.COIN_ID) then
            self._txtItem.text = count .. item.name
        else
            self._txtItem.text = item.name
        end
        self._txtItem.color = ColorDataManager.GetColorByQuality(item.quality)
        ProductManager.SetIconSprite(self._imgItem, item.icon_id)
        self._duration = DropItem.duration
        self._moveToPlayerDuration = 0
        self._timer = Timer.New( function() DropItem._OnTimerHandler(self) end, 0, -1, false);
        self._timer:Start();
        -- 抛物线中的a参数
        self.a = -4 * DropItem.height / math.pow(DropItem.dropTime, 2)
        -- 抛物线中的b参数
        self.b = self.a *(-1) * DropItem.dropTime

        if (item.quality == 3) then
            self._specEffect = Resourcer.Get("Effect/UIEffect", ResID.UI_DROPPURPLE)
            Util.SetPos(self._specEffect, self._targetPos.x, self._targetPos.y, self._targetPos.z)
            --            self._specEffect.transform.position = self._targetPos
        elseif item.quality == 4 then
            self._specEffect = Resourcer.Get("Effect/UIEffect", ResID.UI_DROPORANGE)
            Util.SetPos(self._specEffect, self._targetPos.x, self._targetPos.y, self._targetPos.z)
            --            self._specEffect.transform.position = self._targetPos
        end
    end
end

function DropItem:Dispose()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end

    if (self._effect) then
        Resourcer.Recycle(self._effect)
        self._effect = nil
    end

    if (self._specEffect) then
        Resourcer.Recycle(self._specEffect)
        self._specEffect = nil
    end

    if (self.gameObject) then
        Resourcer.Recycle(self.gameObject)
    end

    self.gameObject = nil
    self.transform = nil
end 

function DropItem:_OnTimerHandler()
    if (self.gameObject and self.transform) then
        if (self._time < DropItem.dropTime) then
            local pt = UIUtil.WorldToUI(self._targetPos);
            self._time = self._time + Timer.deltaTime

            local y = self.a * math.pow(self._time, 2) + self.b * self._time
            pt = pt + Vector3.up * y
            Util.SetPos(self.gameObject, pt.x, pt.y, pt.z)
            --            self.transform.position = pt;
        else
            if (self._duration > 0) then
                local pt = UIUtil.WorldToUI(self._targetPos);
                Util.SetPos(self.gameObject, pt.x, pt.y, pt.z)
                --                self.transform.position = pt;
                self._duration = self._duration - Timer.deltaTime
            else
                if (self._specEffect) then
                    Resourcer.Recycle(self._specEffect)
                    self._specEffect = nil
                end
                self._timer:Stop();
                --                self._timer = nil;

                self.gameObject:SetActive(false)
                self._effect = Resourcer.Get("Effect/UIEffect", ResID.UI_DROPITEMFLYEFFECT)
                local hero = HeroController.GetInstance()
                if (hero and self._effect) then
                    Util.SetPos(self._effect, self._targetPos.x, self._targetPos.y, self._targetPos.z)

                    --                    self._effect.transform.position = self._targetPos
                end
                self._timer:Reset( function() DropItem._MoveToTarget(self) end, 0, -1, false)
                self._timer:Start()
            end
        end
    end
end

function DropItem:_MoveToTarget()
    local hero = HeroController.GetInstance()
    if (hero and self._effect) then
        self._moveToPlayerDuration = self._moveToPlayerDuration + Timer.deltaTime
        Util.SetPos(self._effect, Vector3.MoveTowards(self._effect.transform.position, hero:GetCenter().position, DropItem.speed))

        --        self._effect.transform.position = Vector3.MoveTowards(self._effect.transform.position, hero:GetCenter().position, DropItem.speed)

        if (Vector3.Distance(self._effect.transform.position, hero:GetCenter().position) < 0.05) then
            --            self._timer:Stop();
            self:Dispose()
        end
    end
end


