-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      英雄传记
-- <br/> 2019年1月14日
-- --------------------------------------------------------------------
HeroLibraryStoryPanel = HeroLibraryStoryPanel or BaseClass(BaseView)

local string_format = string.format

function HeroLibraryStoryPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/hero_library_story_panel"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("herolibrary", "herolibrary"), type = ResourcesType.plist},
    }
end

function HeroLibraryStoryPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)  
    self.attr_name = self.main_container:getChildByName("attr_name")
    self.content_scrollview = self.main_container:getChildByName("content_scrollview")
    self.content_scrollview:setScrollBarEnabled(false)
    -- self.content_scrollview:setTouchEnabled(false)
    self.content_scrollview_size = self.content_scrollview:getContentSize()
end

function HeroLibraryStoryPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
end

--关闭
function HeroLibraryStoryPanel:onClickBtnClose()
    HeroController:getInstance():openHeroLibraryStoryPanel(false)
end


--@ name 传记名字
--@ content 传记内容
function HeroLibraryStoryPanel:openRootWnd(name, content)
    if not name and not content then return end
    
    self.attr_name:setString(name)

    local val = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 1), cc.p(self.content_scrollview_size.width * 0.5,0), 12, nil, self.content_scrollview_size.width)
    self.content_scrollview:addChild(val)
    val:setString(content)
    local size = val:getContentSize()
    if size.height < self.content_scrollview_size.height then
        self.content_scrollview:setTouchEnabled(false)
    end
    local scroll_heigt = math.max(self.content_scrollview_size.height, size.height) 
    self.content_scrollview:setInnerContainerSize(cc.size(self.content_scrollview_size.width, scroll_heigt))
    val:setPositionY(scroll_heigt)
end


function HeroLibraryStoryPanel:close_callback()
    HeroController:getInstance():openHeroLibraryStoryPanel(false)
end