TipsSpiritAptitudeView = TipsSpiritAptitudeView or BaseClass(BaseView)
local aptitude_type = {"gongji_zizhi", "fangyu_zizhi", "maxhp_zizhi"}
function TipsSpiritAptitudeView:__init()
    self.ui_config = {"uis/views/tips/spirittips_prefab", "SpiritTip"}
end

function TipsSpiritAptitudeView:__delete()

end

function TipsSpiritAptitudeView:LoadCallBack()
    --获取变量
    self.level_name = {}
    self.level_need = {}
    self.level_addition = {}
    self.modle_effect = {}
    self.effect_root = {}
    self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))

    self.show_next = self:FindVariable("ShowNext")
    for i = 1, 2 do
        self.level_name[i] = self:FindVariable("LevelName" .. i)
        self.level_need[i] = self:FindVariable("LevelNeed" .. i)
        self.level_addition[i] = self:FindVariable("LevelAddition" .. i)

        self.effect_root[i] = self:FindObj("Effect" .. i)
    end
    self.show_now = self:FindVariable("ShowNow")
    self.wuxing_data = SpiritData.Instance:GetWuXing()
    self.maxlevel = #self.wuxing_data
end

function TipsSpiritAptitudeView:ReleaseCallBack()
    self.show_next = nil
    self.level_name = nil
    self.level_need = nil
    self.level_addition = nil
    self.show_now = nil
    self.modle_effect = nil
    self.effect_root = nil
    self.data = nil
end

function TipsSpiritAptitudeView:CloseWindow()
    self:Close()
end

function TipsSpiritAptitudeView:CloseCallBack()
end

function TipsSpiritAptitudeView:OpenCallBack()
	if self.spirit_data then 
    	self:GetAdditionLevel()
   	 	self:InitData()
   		self:SetView()
        self:DisposeAdditionLevel()
   		
   	end
end

function TipsSpiritAptitudeView:GetAdditionLevel()
    -- body
    self.level_total_need=self.spirit_data.title_needs
    self.title_effect=self.spirit_data.title_effect
    self.max_addition_level=#self.level_total_need
    self.addition_level = 0
    for i = 1, self.max_addition_level do
        if tonumber(self.spirit_data.wu_xing) >= tonumber(self.level_total_need[i]) then
            self.addition_level = self.addition_level + 1
        end
    end
end

function TipsSpiritAptitudeView:SetView()
    -- body
    if self.data then
        for i = 1, 2 do
            self.level_name[i]:SetValue(self.data.name[i])
            self.level_need[i]:SetValue(self.data.need[i])
            local value = self.data.addition[i] or 0
            self.level_addition[i]:SetValue(value / 100 .. "%" )
            self:LoadEffect(i,self.data.effect[i],self.effect_root[i])
        end
    end
end

function TipsSpiritAptitudeView:InitData()
    -- body
    -- local data = ConfigManager.Instancep:GetAutoConfig("")
    local data = SpiritData.Instance:GetWuXing()
    if data then
        self.data = {}
        self.data.name = {}
        self.data.need = {}
        self.data.addition = {}
        self.data.effect = {}
        -- 当悟性加成等级为0的时候 total_need全部有值
        -- 当悟性加成等级不为0的时候，total_need只有i=2时有值
        local x = 2
        for i = 1, x do
            if self.spirit_data.titles[self.addition_level + i] and self.spirit_data.titles[self.addition_level + i] then
                self.data.name[i] = "<color=#0000f1>" .. self.spirit_data.titles[self.addition_level + i] .. "</color>"
                self.data.effect[i] = self.title_effect[self.addition_level + i]
                if i ~= 2 then
                    if self.maxlevel <= self.spirit_data.wu_xing then
                        self.data.need[i] = self:DisposeNeedText(self.spirit_data.wu_xing, TEXT_COLOR.BLUE_4)
                    else 
                        -- self.data.need[i] = self:DisposeNeedText(self.spirit_data.wu_xing, TEXT_COLOR.RED)
                        self.data.need[1] = self:DisposeNeedText(self.spirit_data.wu_xing, TEXT_COLOR.BLUE_SPECIAL)
                        self.data.need[2] = self:DisposeNeedText(self.spirit_data.wu_xing, TEXT_COLOR.RED)
                    end
                else
                    -- self.data.need[i] = self:DisposeNeedText(self.spirit_data.wu_xing, TEXT_COLOR.RED) .. self:DisposeNeedText(" / " .. self.level_total_need[self.addition_level + 1], TEXT_COLOR.BLUE_4)
                    self.data.need[1] = self:DisposeNeedText(self.spirit_data.wu_xing, TEXT_COLOR.BLUE_SPECIAL)
                    self.data.need[2] = self:DisposeNeedText(self.spirit_data.wu_xing, TEXT_COLOR.RED) .. self:DisposeNeedText(" / " .. self.level_total_need[self.addition_level + 1], TEXT_COLOR.BLUE_4)
                end
                -- if i ~= 2 then
                    self.data.addition[i] = self.spirit_data.extra_attr[self.addition_level + i]
                -- else
                --     self.data.addition[i] = self.spirit_data.aptitude_list[i].next_value - self.spirit_data.aptitude_list[i].original_value
                -- end
            end
        end 
    end
end

function TipsSpiritAptitudeView:SetData(data)
    self.spirit_data = data
end



function TipsSpiritAptitudeView:DisposeAdditionLevel()
    -- body
    if self.addition_level == 0 then
        self.show_next:SetValue(true)
        self.show_now:SetValue(false)
    elseif self.addition_level == 4 then
        self.show_next:SetValue(false)
        self.show_now:SetValue(true)
    else
        self.show_next:SetValue(true)
        self.show_now:SetValue(true)
    end
end

function TipsSpiritAptitudeView:DisposeNeedText(data, color)
    -- body
    data = ToColorStr(data .. "级", color)
    return data
end

function TipsSpiritAptitudeView:LoadEffect(index,itemdata,model_root)
    if self.modle_effect[index] then
        GameObject.Destroy(self.modle_effect[index])
        self.modle_effect[index] = nil
    end

    if itemdata and itemdata ~= "" then
        PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_jinglinminghun/" .. itemdata .. "_prefab", itemdata), function (prefab)
                if not prefab then return end

                local obj = GameObject.Instantiate(prefab)
                PrefabPool.Instance:Free(prefab)
                local transform = obj.transform
                transform:SetParent(model_root.transform, false)
                self.modle_effect[index] = obj.gameObject
            end)
    end
end