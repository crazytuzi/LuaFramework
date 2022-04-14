--
-- @Author: LaoY
-- @Date:   2018-11-26 16:08:18
--
MapPanel = MapPanel or class("MapPanel", WindowPanel)
local MapPanel = MapPanel

function MapPanel:ctor()
    self.abName = "map"
    self.assetName = "MapPanel"
    self.layer = "UI"

    -- self.change_scene_close = true 				--切换场景关闭
    -- self.default_table_index = 1					--默认选择的标签
    self.is_show_money = false

    self.panel_type = 2                --窗体样式  1 1280*720  2 850*545
    self.show_sidebar = true        --是否显示侧边栏
    if self.show_sidebar then
        -- 侧边栏配置
        self.sidebar_data = {
            { text = "Zone", id = 1, img_title = "map:img_text_title_1" },
            { text = "World", id = 2, img_title = "map:img_text_title_1" },
        }
    end
    self.table_index = nil
end

function MapPanel:dctor()
    if self.mini_panel then
        self.mini_panel:destroy()
        self.mini_panel = nil
    end
    if self.world_panel then
        self.world_panel:destroy()
        self.world_panel = nil
    end
end

function MapPanel:Open()
    MapPanel.super.Open(self)
end

function MapPanel:LoadCallBack()
    self.nodes = {
        "",
    }
    self:GetChildren(self.nodes)

    self:AddEvent()
end

function MapPanel:AddEvent()
    local function callback()
        self:Close()
    end
    self.close_event_id = GlobalEvent:AddListener(MapEvent.CloseMapPanel, callback)
end

function MapPanel:OpenCallBack()
    self:UpdateView()
end

function MapPanel:UpdateView()

end

function MapPanel:CloseCallBack()

end
function MapPanel:SwitchCallBack(index)
    if self.table_index == index then
        return
    end
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    self.table_index = index
    if self.table_index == 1 then
        if not self.mini_panel then
            self.mini_panel = MapMiniPanel(self.transform)
        end
        self:PopUpChild(self.mini_panel)
    elseif self.table_index == 2 then
        if not self.world_panel then
            self.world_panel = MapWorldPanel(self.transform)
        end
        self:PopUpChild(self.world_panel)
    end
end