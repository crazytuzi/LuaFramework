local _M = {}
_M.__index = _M
local Util = require "Zeus.Logic.Util"
local ActivityModel = require "Zeus.Model.Activity"
local TreeView = require "Zeus.Logic.TreeView"

local self = {menu = nil}


local function InitNoticeList(noticeList)
    for i = 1,#noticeList do
        local node = self.cvs_frame:Clone()
        node.Visible = true
        node:FindChildByEditName("lb_aname", false).Text = noticeList[i].NoticeTitle
        node:FindChildByEditName("lb_date", false).Text = string.sub(noticeList[i].ReleaseTime,1,10) 
        node:FindChildByEditName("ib_icon1", false).Visible = (noticeList[i].HaveRead == true) 
        
        node.Y = (i-1)*self.cvs_frame.Height
        self.sp_sp:AddChild(node)
    end
end



local rootValue
local function FuncCancel(node)
    
    
end

local function InitTreeView(self,noticeList)
    
    local subValues = {}
    local nodeValues = {}

    local function getNodeIndex(node)
        for i = 1,#nodeValues do
            if nodeValues[i].UserTag == node.UserTag then
                return i
            end
        end
        return 1
    end

    local function subCreateCallback(rootIndex,subIndex,node)
        node.Enable = true
        
        local tb_content = node:FindChildByEditName("tb_content",false)
        tb_content.XmlText = noticeList[rootIndex].Content
        node.Height = tb_content.TextComponent.RichTextLayer.ContentHeight + 25
        tb_content.Height = tb_content.TextComponent.RichTextLayer.ContentHeight + 25

        
        
        
        
        
    end

    local function subClickCallback(rootIndex,subIndex,node)
        
        
        
    end

    local function rootCreateCallBack(index,node)
        node.Enable = true
        node:FindChildByEditName("lb_aname", false).Text = noticeList[index].NoticeTitle
        node:FindChildByEditName("lb_date", false).Text = string.sub(noticeList[index].ReleaseTime,1,10) 
        node:FindChildByEditName("ib_icon1", false).Visible = (noticeList[index].isRead == 0) 
        node.UserTag = noticeList[index].ID

        local subValue = TreeView.CreateSubValue(index,self.cvs_frame2,1,subClickCallback,subCreateCallback)
        table.insert(subValues,subValue)
        table.insert(nodeValues,node)
    end
    local currentNodeId = 0
    local function rootClickCallBack(node,visible)
        local tbt_ic1 = node:FindChildByEditName("tbt_ic1",false)
        node:FindChildByEditName("cvs_frcol", false).Visible = visible
        
        if visible then
            Util.HZSetImage(tbt_ic1, "#static_n/func/common1.xml|common1|31")
            
            local readPoint = node:FindChildByEditName("ib_icon1", false)
            if readPoint~= nil and readPoint.Visible == true then
                ActivityModel.requestAward(15, node.UserTag, function()
                    
                end)
                readPoint.Visible = false
            end
            
            
            if currentNodeId ~= node.UserTag then
                currentNodeId = node.UserTag
                
            end
        else
            Util.HZSetImage(tbt_ic1, "#static_n/func/common1.xml|common1|32")
        end
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('buttonClick')
    end
    rootValue = TreeView.CreateRootValue(self.cvs_frame,#noticeList,rootCreateCallBack,rootClickCallBack)
    
    self.treeView:setValues(rootValue,subValues)
    self.sp_sp:AddNormalChild(self.treeView.view)
    self.treeView:setScrollPan(self.sp_sp)
end

function  _M.OnEnter()
    ActivityModel.activityNoticeRequest(function(params)
        if #params > 0 then
            if self.treeView ~= nil then
                self.sp_sp:RemoveNormalChild(self.treeView.view,true)
            end

            self.treeView = TreeView.Create(3,0,self.sp_sp.Size2D,TreeView.MODE_SINGLE,FuncCancel)
            InitTreeView(self,params)
            self.treeView:selectNode(1,1,true)
        else
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.SIGN, "noserverdata"))
        end
    end)
end

function _M.OnExit()

end

local ui_names = 
{
    {name = 'cvs_all'},
    {name = 'tbt_ic1'},
    {name = 'sp_sp'},
    {name = 'cvs_frame'}, 
    {name = 'cvs_frame2'}, 
}

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.event_PointerClick = function()
                ui.click(tbl)
                end
            end
        end
    end
end

local function InitComponent(self,xmlPath)
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)
    initControls(self.menu,ui_names,self)
    self.cvs_frame.Visible = false
    self.cvs_frame2.Visible = false

    return self.menu
end

local function Create(ActivityID,xmlPath)
    self = {}
    self.ActivityID = ActivityID
    setmetatable(self, _M)
    local node = InitComponent(self,xmlPath)
    return self,node
end

return {Create = Create}
