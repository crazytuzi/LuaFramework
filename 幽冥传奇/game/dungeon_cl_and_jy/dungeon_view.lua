DungeonView = DungeonView or BaseClass(BaseView)

function DungeonView:__init()
    self.title_img_path = ResPath.GetWord("word_fuben")
    self.texture_path_list[1] = "res/xui/fuben_cl.png"
    self.texture_path_list[2] = "res/xui/fuben.png"
    self:SetModal(true)
    self:SetBackRenderTexture(true)
    
    self.config_tab = {
        {"common_ui_cfg", 1, {0}},
        -- {"fuben_cl_and_jy_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil , 999},
    }
    require("scripts/game/dungeon_cl_and_jy/dungeon_cl_view").New(ViewDef.Dungeon.Material, self)
    require("scripts/game/dungeon_cl_and_jy/dungeon_jy_view").New(ViewDef.Dungeon.Experience, self)
    require("scripts/game/dungeon_cl_and_jy/lianyu_view").New(ViewDef.Dungeon.LianYu, self)
end

function DungeonView:__delete()
    
end

function DungeonView:ReleaseCallBack()
    if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function DungeonView:LoadCallBack()
    self:InitEquipTypeTabbar()
end

function DungeonView:CloseCallBack()
    
end

function DungeonView:OpenCallBack()
    DungeonCtrl.EnterFubenReq(3,0,0)
end


function DungeonView:InitEquipTypeTabbar()
    self.view_group = {ViewDef.Dungeon.Material, ViewDef.Dungeon.Experience, ViewDef.Dungeon.LianYu}
    self.tab_group = {ViewDef.Dungeon.Material.name, ViewDef.Dungeon.Experience.name,  ViewDef.Dungeon.LianYu.name}
    
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
        self.tabbar:SetTabbtnTxtOffset(2, 10)
        self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650,
            function (index) ViewManager.Instance:OpenViewByDef(self.view_group[index]) end,
            self.tab_group, true, ResPath.GetCommon("toggle_110"), 20, true)
		self.tabbar:SetSpaceInterval(10)
		self.tabbar:GetView():setLocalZOrder(100)
	end
end

function DungeonView:SelectTabCallback()
    -- body
end

function DungeonView:ShowIndexCallBack(index)
    self:Flush(index)
    for k, v in pairs(self.view_group) do
        if ViewManager.Instance:IsOpen(v) then
            self.tabbar:ChangeToIndex(k)
            break
        end
    end
end

function DungeonView:OnFlush(param_list, index)
    for i,v in ipairs(DungeonData.Instance:GetRemindFunc()) do
        self.tabbar:SetRemindByIndex(i, v())
    end
end