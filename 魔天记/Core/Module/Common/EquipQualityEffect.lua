local EquipQualityEffect = class("EquipQualityEffect")

function EquipQualityEffect:New()
    self = { };
    setmetatable(self, { __index = EquipQualityEffect });

    return self;
end

function EquipQualityEffect:StopEffect()
    if self._eqQualityspecEffect ~= nil then
        self._eqQualityspecEffect:Stop()
    end

    if self.uiSprite ~= nil then
        FixedUpdateBeat:Remove(self.UpTime, self);
        self.uiSprite.gameObject:SetActive(false);
        self:SetEfActive(false);
    end

end

function EquipQualityEffect:TryCheckEquipQualityEffect(parent, tag, type, quality)

    -- self:StopEffect();
    -- http://192.168.0.8:3000/issues/7984
    if ProductManager.type_1 == type and quality >= 5 then
        if self._eqQualityspecEffect == nil then
            self._eqQualityspecEffect = UIEffect:New();
            self._eqQualityspecEffect:Init(parent, tag, 0, "ui_zhuangtai_0")
        end

        self._eqQualityspecEffect:Play();
        self._eqQualityspecEffect:GetParticle("lizi");

        --[[		if quality == 5 then
			self._eqQualityspecEffect:SetColor(255, 142, 0, 255);
		elseif quality == 6 then
			self._eqQualityspecEffect:SetColor(255, 20, 0, 255);
		end		
        ]]
    else
        self:StopEffect();
    end

end

function EquipQualityEffect:TryCheckEquipQualityEffectForUISprite(uiSprite,type, quality)
   
    self.uiSprite = uiSprite;
    self:SetEfActive(false);
    FixedUpdateBeat:Remove(self.UpTime, self);
    if ProductManager.type_1 == type and quality >= 5 then
        self.max_frame = 24;
        self.curr_frame = 0;
        self:SetEfActive(true);
        self.uiSprite.spriteName = string.format("%.2d", self.curr_frame);
        FixedUpdateBeat:Add(self.UpTime, self);
    end

end

function EquipQualityEffect:SetEfActive(v)
   
   self.active = v;
   self.uiSprite.gameObject:SetActive(v);
end

function EquipQualityEffect:UpTime()

    if self.curr_frame <= self.max_frame then
        self.uiSprite.spriteName = string.format("%.2d", self.curr_frame);
        self.curr_frame = self.curr_frame + 1;
    else
        self.curr_frame = 0;
    end

end

function EquipQualityEffect:Dispose()

    FixedUpdateBeat:Remove(self.UpTime, self);

    if (self._eqQualityspecEffect) then
        self._eqQualityspecEffect:Dispose()
        self._eqQualityspecEffect = nil
    end
    self.uiSprite = nil;


end

return EquipQualityEffect; 