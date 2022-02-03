-- --------------------------------------------------------------------
-- 众神战场的击杀或者被击杀提示
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
GodBattleKillNoticeView = GodBattleKillNoticeView or BaseClass(BaseView)

local controller = GodbattleController:getInstance()

function GodBattleKillNoticeView:__init()
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "godbattle/godbattle_kill_notice_view"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("godbattle", "godbattle"), type = ResourcesType.plist}
    }
end

function GodBattleKillNoticeView:open_callback()
    self.main_container = self.root_wnd:getChildByName("main_container")

    self.left_head = self.main_container:getChildByName("left_head")
    self.left_role = PlayerHead.new(PlayerHead.type.circle)
    self.left_role:setAnchorPoint(0.5, 0.5)
    self.left_role:setScale(0.5)
    self.left_role:setPosition(self.left_head:getContentSize().width/2, self.left_head:getContentSize().height/2)
    self.left_head:addChild(self.left_role)

    self.right_head = self.main_container:getChildByName("right_head")
    self.right_role = PlayerHead.new(PlayerHead.type.circle)
    self.right_role:setAnchorPoint(0.5, 0.5)
    self.right_role:setScale(0.5)
    self.right_role:setPosition(self.right_head:getContentSize().width/2, self.right_head:getContentSize().height/2)
    self.right_head:addChild(self.right_role)

    self.top_img =  self.main_container:getChildByName("top_img")
    self.bottom_img = self.main_container:getChildByName("bottom_img")
    self.left_frame = self.main_container:getChildByName("left_frame")
    self.right_frame = self.main_container:getChildByName("right_frame")
    self.notice_txt = self.main_container:getChildByName("notice_txt")
    self.left_name = self.main_container:getChildByName("left_name")
    self.right_name = self.main_container:getChildByName("right_name")
end

function GodBattleKillNoticeView:register_event()
end

function GodBattleKillNoticeView:openRootWnd(data)
    self.data = data
    local txt_res = nil
    if data.type <= 6 then
        txt_res = PathTool.getResFrame("godbattle", "txt_cn_godbattle_"..data.type)
        -- if data.type == 1 then  -- 五杀
        --     playOtherSound("c_unstopable")
        -- elseif data.type == 2 then  -- 超神
        --     playOtherSound("c_godbless")
        -- end
    end
    if txt_res ~= nil then
        loadSpriteTexture(self.notice_txt, txt_res, LOADTEXT_TYPE_PLIST)
    end

    if data.camp1 == GodBattleConstants.camp.god then
        loadSpriteTexture(self.top_img, PathTool.getResFrame("godbattle", "godbattle_15"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.bottom_img, PathTool.getResFrame("godbattle", "godbattle_15"), LOADTEXT_TYPE_PLIST)

        loadSpriteTexture(self.left_frame, PathTool.getResFrame("godbattle", "godbattle_17"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.right_frame, PathTool.getResFrame("godbattle", "godbattle_18"), LOADTEXT_TYPE_PLIST)
    else
        loadSpriteTexture(self.top_img, PathTool.getResFrame("godbattle", "godbattle_16"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.bottom_img, PathTool.getResFrame("godbattle", "godbattle_16"), LOADTEXT_TYPE_PLIST)

        loadSpriteTexture(self.left_frame, PathTool.getResFrame("godbattle", "godbattle_18"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.right_frame, PathTool.getResFrame("godbattle", "godbattle_17"), LOADTEXT_TYPE_PLIST)
    end
    self.left_role:setHeadRes(data.face1)
    self.left_name:setString(transformNameByServ(data.name1,data.srv_id1))

    self.right_role:setHeadRes(data.face2)
    self.right_name:setString(data.name2)
    self.right_name:setString(transformNameByServ(data.name2,data.srv_id2))
    setChildUnEnabled(true,self.right_role)
    self:timeCountDown()
end

function GodBattleKillNoticeView:timeCountDown()
    if self.timer == nil then
        self.timer = GlobalTimeTicket:getInstance():add(function() 
            self:close()
            -- controller:openGodBattleKillNoticeView(false)
        end, 2)
    end
end

function GodBattleKillNoticeView:clearTimer()
    if self.timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.timer)
        self.timer = nil
    end
end

function GodBattleKillNoticeView:close_callback()
    if self.left_role then
        self.left_role:DeleteMe()
    end
    self.left_role = nil
    if self.right_role then
        self.right_role:DeleteMe()
    end
    self.right_role = nil
    controller:openGodBattleKillNoticeView(false)
    self:clearTimer()
end
