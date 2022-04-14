-- 
-- @Author: LaoY
-- @Date:   2018-07-25 16:02:55
-- 

require("common.input.GMSubPanel")
require("common.input.GMTestPanel")

GMPanel = GMPanel or class("GMPanel",WindowPanel)
local GMPanel = GMPanel

function GMPanel:ctor()
    self.abName = "debug"
    self.assetName = "GMPanel"
    self.layer = "UI"

    -- self.change_scene_close = true                 --切换场景关闭
    -- self.default_table_index = 1                    --默认选择的标签
    -- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}    --是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
    
    self.panel_type = 2                                --窗体样式  1 1280*720  2 850*545
    self.show_sidebar = true        --是否显示侧边栏
    if self.show_sidebar then        -- 侧边栏配置
        self.sidebar_data = {
            { text = "GM", id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n" },
            { text = "Log", id = 3, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n" },
            { text = "Test", id = 2, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n" },
        }
    end
    self.table_index = nil
end

function GMPanel:dctor()
    if self.gm_sub_panel then
        self.gm_sub_panel:destroy()
        self.gm_sub_panel = nil
    end

    if self.gm_test_panel then
        self.gm_test_panel:destroy()
        self.gm_test_panel = nil
    end

    if self.close_event then
        GlobalEvent:RemoveListener(self.close_event)
        self.close_event = nil
    end
end

function GMPanel:Open( )
    GMPanel.super.Open(self)
end

function GMPanel:LoadCallBack()
    self.nodes = {
        "",
    }
    self:GetChildren(self.nodes)

    self:AddEvent()
end

function GMPanel:AddEvent()
    -- self.close_event = GlobalEvent:AddListener(MainEvent.CloseGMSubPanel, handler(self, self.Close))
end

function GMPanel:OpenCallBack()
    self:UpdateView()
end

function GMPanel:UpdateView( )

end

function GMPanel:CloseCallBack(  )

end
function GMPanel:SwitchCallBack(index)
    if self.table_index == index then
        return
    end
    if self.child_node then
         self.child_node:SetVisible(false)
    end
    self.table_index = index
    if self.table_index == 1 then
        if not self.gm_sub_panel then
            self.gm_sub_panel = GMSubPanel(self.transform)
        end
        self:PopUpChild(self.gm_sub_panel)
    elseif self.table_index == 2 then
        if not self.gm_test_panel then
            self.gm_test_panel = GMTestPanel(self.transform)
        end
        self:PopUpChild(self.gm_test_panel)
    end
end