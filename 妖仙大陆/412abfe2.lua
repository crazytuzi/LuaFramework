local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local SoloAPI = require "Zeus.Model.Solo"

local function reverseTable(tab) 
    local tmp = {}  
    for i = 1, #tab do  
        local key = #tab  
        tmp[i] = table.remove(tab)
    end  

    return tmp  
end

local function initList(self,datas)

    local nodeY = self.cvs_single.Y

    local function UpdateItem(gy,node)
        node.Visible = true
        local data = datas[gy]
        
        local lb_day = node:FindChildByEditName('lb_day',false)
        local cvs_word = node:FindChildByEditName('cvs_word',false)
        

        cvs_word.Visible = false


        lb_day.Text = data.date
        local h = 0
        local count = #data.message
        for i,v in ipairs(data.message) do
            local index = count-i+1
            local info = nil
            info = cvs_word:Clone()
            local tb_word = info:FindChildByEditName('tb_word',false)
            if index - math.floor(index/2)*2 == 1 then
                info.Enable = false
            else
                info.Enable = true
            end
            info.Visible = true
            tb_word.XmlText = "<f>" .. v .."</f>"
            info.X  = cvs_word.X
            info.Y  = cvs_word.Y + (index -1) *cvs_word.Height
            node:AddChild(info)
        end

        node.Height = cvs_word.Y + #data.message * cvs_word.Height
    end

    for i=1,#datas do
        local itemNode = self.cvs_single:Clone()
        UpdateItem(i,itemNode)
        itemNode.Y = nodeY
        nodeY = nodeY + itemNode.Height
        self.sp_show.Scrollable.Container:AddChild(itemNode)
    end
    
    

end

function _M:OnEnter()
    self.menu.Visible = false
	SoloAPI.requestNewsInfo(function(datas)
        self.menu.Visible = true
        if datas and #datas>0 then
            initList(self,reverseTable(datas))
        end
    end)
end

function _M:OnExit()

end

local ui_names = 
{
    {name = 'cvs_single'},
    {name = 'sp_show'}
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

local function InitComponent(self)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/solo/solo_news.gui.xml')
    initControls(self.menu,ui_names,self)
    self.cvs_single.Visible = false

    return self.menu
end

function _M.Create()
    local ret = {}
    setmetatable(ret,_M)
    local node = InitComponent(ret)
    return ret,node
end

return _M
