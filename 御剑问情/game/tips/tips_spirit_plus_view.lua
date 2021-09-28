TipsSpiritPlusView = TipsSpiritPlusView or BaseClass(BaseView)
local aptitude_type = {"gongji_zizhi", "fangyu_zizhi", "maxhp_zizhi"}
function TipsSpiritPlusView:__init()
    self.ui_config = {"uis/views/tips/spirittips_prefab", "SpiritTip01"}
end

function TipsSpiritPlusView:__delete()

end

function TipsSpiritPlusView:LoadCallBack()
    --获取变量
    self.level_name = {}
    self.level_need = {}
    self.level_addition = {}
    self.modle_effect = {}
    self.effect_root = {}
    self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))

    self.show_next = self:FindVariable("ShowNext")
    self.show_img = {}
    for i = 1, 2 do
        self.level_name[i] = self:FindVariable("LevelName" .. i)
        self.level_need[i] = self:FindVariable("LevelNeed" .. i)
        self.show_img[i] = self:FindVariable("show_img_" .. i)
        -- self.level_addition[i] = self:FindVariable("LevelAddition" .. i)
    end
    self.now_attr_list = {}
    self.next_attr_list = {}
    for i = 1, 3 do
        self.now_attr_list[i] = self:FindVariable("now_attr_value_" .. i)
        self.next_attr_list[i] = self:FindVariable("next_attr_value_" .. i)
    end
    self.show_now = self:FindVariable("ShowNow")
    -- self.wuxing_data = SpiritData.Instance:GetWuXing()
    -- self.maxlevel = #self.wuxing_data
end

function TipsSpiritPlusView:ReleaseCallBack()
    self.show_next = nil
    self.level_name = nil
    self.level_need = nil
    self.level_addition = nil
    self.show_now = nil
    self.modle_effect = nil
    self.effect_root = nil
    self.data = nil
    self.now_attr_list = nil
    self.next_attr_list = nil
    self.show_img = nil
end

function TipsSpiritPlusView:FlushTitleFrame()
    local spirit_data = SpiritData.Instance
    -- local info = spirit_data:GetLingPoInfo(self.cur_lingpo_list[self.cur_index].type)
    -- if not info or not next(info) then return end
   
    local attr_list = spirit_data:GetLingPoTitleAttr()
    local now_list = spirit_data:GetLingPoNowTitleAttr()
    for i=1, 4 do
        if 4 == i then
            self.level_name[1]:SetValue(now_list[i])
            self.level_name[2]:SetValue(attr_list[i])
        else
            self.next_attr_list[i]:SetValue(attr_list[i])
            self.now_attr_list[i]:SetValue(now_list[i])
        end
    end
    local title_info = spirit_data:GetCurTitleInfo()
    self.level_need[2]:SetValue(title_info.desc)
    self.level_need[1]:SetValue(title_info.desc2)

    local now_title_info = spirit_data:GetCurNowTitleInfo()
    self.show_img[2]:SetAsset(ResPath.GetTitleIcon(title_info.title_id))
    self.show_img[1]:SetAsset(ResPath.GetTitleIcon(now_title_info.title_id))

    local max_level, max_id = TitleData.Instance:GetLingPoMaxLevel()
    local my_level = spirit_data:GetLingPoTotalLevel()
    local cfg = ConfigManager.Instance:GetAutoConfig("titleconfig_auto").jingling_card_title[1]
    if now_title_info.title_id == max_id then
        self.show_next:SetValue(false)
    else
        self.show_next:SetValue(true)
    end
    if my_level < cfg.level then
        self.show_now:SetValue(false)
    else
        self.show_now:SetValue(true)
    end
end

function TipsSpiritPlusView:CloseWindow()
    self:Close()
end

function TipsSpiritPlusView:CloseCallBack()

end

function TipsSpiritPlusView:OpenCallBack()
	if self.spirit_data then 
        self:FlushTitleFrame()
   	end
end

function TipsSpiritPlusView:SetData(data)
    self.spirit_data = data
end


