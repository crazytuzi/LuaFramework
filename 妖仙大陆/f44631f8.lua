local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local SliderExt = require "Zeus.Logic.SliderExt"
local GSApi = require "Zeus.Model.GS"

local ui_names = 
{
	"gg_hp",
	"ib_top",
	"lb_num",
    "tbt_g1",
    "tbt_g2",
    "tbt_g3",
	"tbt_gou1",
	"tbt_gou2",
	"tbt_gou3",
	"tbt_gou4",
	"tbt_gou5",
	"tbt_gou6",
	"tbt_gou7",
	"tbt_gou8",
	"tbt_gou9",
	"tbt_gou10",
	"tbt_gou11",
	"btn_1",
	"btn_2",
	"btn_3"
}

local keyNames = 
{
	"gs_fx",
	"gs_skill_fx",
	"gs_title_self",
	"gs_title_others",
	"gs_blood",
	"gs_guild",
	"gs_name",
	"gs_team",
	"gs_friend",
	"gs_music",
	"gs_sound",

}

function _M:setVisible(visible)
    self.menu.Visible = visible
end

local function initSettingFuncMap(self)
    self.settingFuncMap = {
    	
    	[GameSetting.FX] = function(IsChecked, value)
            QualityManager.Instance.EnableFx = IsChecked
        end,
        
        [GameSetting.SKILL_FX] = function(IsChecked, value)
            GameSetting.SetValue(GameSetting.SKILL_FX, (IsChecked and 0) or 1)
            QualityManager.Instance.EnableSkillFx = not IsChecked
        end,
        
        [GameSetting.TITLE_SELF] = function(IsChecked)
            BattleInfoBarManager.HideMyTitle(not IsChecked)
        end,
        
        [GameSetting.TITLE_OTHERS] = function(IsChecked)
            BattleInfoBarManager.HideAllTitleButMy(not IsChecked)
        end,
        
        [GameSetting.BLOOD] = function(IsChecked)
            BattleInfoBarManager.ChangeShowHpCtrl(IsChecked)
        end,
        
        [GameSetting.GUILD] = function(IsChecked)
            BattleInfoBarManager.HideAllGuild(not IsChecked)
        end,
        
        [GameSetting.NAME] = function(IsChecked)
            BattleInfoBarManager.HideAllName(not IsChecked)
        end,

        
        [GameSetting.MUSIC] = function(IsChecked)
            XmdsSoundManager.GetXmdsInstance():SetBGMMute(not IsChecked)
            
            
            
            
        end,
        
        [GameSetting.SOUND] = function(IsChecked)
            XmdsSoundManager.GetXmdsInstance():SetGetEffectMute(not IsChecked)
            
            
            
            
        end,
        
        
        
        
        
        
        

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
end


local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ctrl = view:FindChildByEditName(names[i], true)
        if (ctrl) then
            tbl[names[i]] = ctrl
        end
    end
end

function _M:OnEnter()
    initSettingFuncMap(self)

    for i=3,11 do
    	local  tbtBtn = self["tbt_gou" .. i]
    	tbtBtn.UserData = keyNames[i]
    	tbtBtn.TouchClick = function(sender)
    		local settingKey = sender.UserData
        	GameSetting.SetValue(settingKey, (sender.IsChecked and 1) or 0)
    		local func = self.settingFuncMap[settingKey]
		    if func then
		        func(sender.IsChecked)
		    end
		    GSApi.saveSetting(settingKey)
    	end 

		local  IsChecked = GameSetting.GetValue(keyNames[i]) == 1 
		if keyNames[i] == GameSetting.SKILL_FX then
            IsChecked = not IsChecked
        end
		tbtBtn.IsChecked = IsChecked
    	local func = self.settingFuncMap[keyNames[i]]
		if func then
		    func(IsChecked)
		end
    end

    local  roleNum = GameSetting.ROLE_NUM
    local  itemData = GlobalHooks.DB.Find("SystemConfig", {Key=roleNum})[1]
    local fun = function(IsChecked, value, max, settingKey, notSaveData)
            value = math.floor(value)
            local gsValue = value > max and max or value
            local ggValue = value < 0 and max or value
            if not notSaveData then
                DataMgr.Instance.UserData.ShowUnitNum = gsValue
                GameSetting.SetValue(settingKey, gsValue)
                GSApi.saveSetting(settingKey)
            end
            
            
            
                return tostring(ggValue), ggValue
            
        end
    local function onSliderChange(value)
            self.lb_num.Text = fun(nil, self.gg_hp.Value, itemData.Max, roleNum, true)
    end
    local function onSliderLastChange(value)
        self.lb_num.Text = fun(nil, self.gg_hp.Value, itemData.Max, roleNum, false)
    end
    local text, ggValue = "0", 0
    text, ggValue = fun(nil, GameSetting.GetValue(roleNum), itemData.Max, roleNum, true)

    self.lb_num.Text = text
    self.gg_hp:SetGaugeMinMax(itemData.Value, itemData.Max)
    SliderExt.New(
        self.gg_hp,
        self.ib_top,
        ggValue,
        onSliderChange,
        true,
        onSliderLastChange
    )
    local text = Util.GetText(TextConfig.Type.GUILD, "qietusuccess")
    local defaultTbt = self["tbt_g" .. (3 - GameSetting.GetValue("gs_quality"))]
    Util.InitMultiToggleButton(function (sender)
        local quality = GameSetting.GetValue("gs_quality")
        if sender == self.tbt_g1 and quality ~= 2 then
            GameSetting.SetValue("gs_quality", 2)
            GameAlertManager.Instance:ShowNotify(text)
            QualityManager.Instance.QualityLv = 2
        elseif sender == self.tbt_g2 and quality ~= 1 then
            GameSetting.SetValue("gs_quality", 1)
            GameAlertManager.Instance:ShowNotify(text)
            QualityManager.Instance.QualityLv = 1
        elseif sender == self.tbt_g3 and quality ~= 0 then
            GameSetting.SetValue("gs_quality", 0)
            GameAlertManager.Instance:ShowNotify(text)
            QualityManager.Instance.QualityLv = 0
        end
        GSApi.saveSetting( )
    end,defaultTbt,{self.tbt_g1,self.tbt_g2,self.tbt_g3})
end

function _M:OnExit()

end

local function InitComponent(self, tag, parent)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/set/shezhi.gui.xml')
    initControls(self.menu,ui_names,self)

    self.parent = parent
    if (parent) then
        parent:AddChild(self.menu)
    end

    self.btn_1.TouchClick = function ()
        local ui,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUISetMain)
        if ui then  
            ui:Close()
            GameSceneMgr.Instance:ExitGame(nil)
        end
    end

    self.btn_2.Visible = SDKWrapper.Instance:HasAccountCenter()
    self.btn_2.TouchClick = function ()
        SDKWrapper.Instance:ShowAccountCenter()
    end

    
    self.btn_3.TouchClick = function ()
        local returnrolelist = Util.GetText(TextConfig.Type.GUILD, "returnrolelist")
        local btnOK = Util.GetText(TextConfig.Type.GUILD, "btnOK")
        local btnCancel = Util.GetText(TextConfig.Type.GUILD, "btnCancel")
        local exitOK = Util.GetText(TextConfig.Type.GUILD, "exitOK")
        GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_SYSTEM, returnrolelist, btnOK, btnCancel, exitOK, nil, 
            function()
                 GameSceneMgr.Instance:GotoSelectRole() 
            end, nil);
    end

end

function _M.Create(tag,parent)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag,parent)
    return ret
end

return _M
