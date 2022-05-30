-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      VedioLookPanel 录像信息
-- <br/> 2019年3月6日
-- --------------------------------------------------------------------
VedioLookPanel = VedioLookPanel or BaseClass(BaseView)

local controller = VedioController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function VedioLookPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "vedio/vedio_look_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
end

function VedioLookPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

  
    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("录像详情"))

    local size = self.main_panel:getContentSize()
    self.cell = VedioMainItem.new(true)
    self.cell:addCallBack(function(world_pos) self:onShowSharePanel(world_pos) end)
    self.cell:addPlayCallBack(function() self:onClickBtnClose() end)
    local image_panel = self.cell.container:getChildByName("image_panel")
    image_panel:getChildByName("image_bg"):setVisible(false)
    self.cell:setPosition(size.width * 0.5 , size.height * 0.5 )
    self.main_panel:addChild(self.cell)
end

function VedioLookPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
   
    -- self:addGlobalEvent(VedioEvent.LOOK_VEDIO_EVENT, function(data)
    --     if not data then return end
    --     self:setData(data)
    -- end)
end

function VedioLookPanel:onShowSharePanel(world_pos)
    if not world_pos then return end
    if not self.data then return end
    local srv_id
    if self.data.combat_type == BattleConst.Fight_Type.CrossChampion and self.data.ext and next(self.data.ext) ~= nil then
        for k,v in pairs(self.data.ext) do
            if v.key == 1 then
                srv_id = v.str
                break
            end
        end
    else
        srv_id = self.data.a_srv_id
    end
    controller:openVedioSharePanel(true, self.data.id, world_pos, function(share_btn_type) self:updateData(share_btn_type) end, srv_id, self.data.combat_type)
end

--关闭
function VedioLookPanel:onClickBtnClose()
    controller:openVedioLookPanel(false)
end


--@vedio_id id
--@svr_id 服务器id
--@_type
function VedioLookPanel:openRootWnd(data)
    -- vedio_id, svr_id, _type
    -- if not vedio_id then return end
    -- if not svr_id then return end
    -- if not _type then return end
    -- controller:send19908( vedio_id, svr_id, _type )
    self:setData(data)
end

function VedioLookPanel:updateData(share_btn_type)
    if not self.data then return end
    if share_btn_type == VedioConst.Share_Btn_Type.eGuildBtn then
        self.data.share = self.data.share + 1
    else -- share_btn_type == VedioConst.Share_Btn_Type.eWorldBtn
        -- 默认世界分享
        self.data.share = self.data.share + 1
    end
    self.cell:setData(self.data)
end

function VedioLookPanel:setData(data)
    self.data = data
    self.cell:setData(data)
end



function VedioLookPanel:close_callback()
    self.data = nil
    controller:openVedioLookPanel(false)
end

