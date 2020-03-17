--
-- Created by IntelliJ IDEA.
-- User: liuyingshuai
-- Date: 2014/10/25
-- Time: 13:14
-- To change this template use File | Settings | File Templates.
--
_G.UIDealOper = BaseUI:new("UIDealOper");

UIDealOper.slotMc   = nil;--mc
UIDealOper.pos      = 0;--格子位置
UIDealOper.operList = nil;--操作列表

function UIDealOper:Create()
    self:AddSWF("bagOperPanel.swf", true, "top");
end

function UIDealOper:OnLoaded(objSwf)
    objSwf.list.itemClick = function(e) self:OnListItemClick(e); end;
end

function UIDealOper:OnShow()
    self:DoShowPanel();
end

function UIDealOper:OnHide()
	self.slotMc = nil;
end

--在目标位置打开操作面板
function UIDealOper:Open( slotMc, pos )
    self.slotMc = slotMc;
    self.pos = pos;
    if self:IsShow() then
        self:DoShowPanel();
    else
        self:Show();
    end
end

function UIDealOper:DoShowPanel()
    local objSwf = self.objSwf;
    if not objSwf then return; end
    local pos = nil;
    if self.slotMc then
        pos = UIManager:GetMcPos(self.slotMc);
        local width = self.slotMc.width or self.slotMc._width;
        local height = self.slotMc.height or self.slotMc._height;
        pos.x = pos.x + width/2;
        pos.y = pos.y + height;
    else
        pos = _sys:getRelativeMouse();
    end
    objSwf._x = pos.x;
    objSwf._y = pos.y-5;

    self.operList = self:GetOperList(self.pos);

    local len = #self.operList;
    if len <= 0 then
        self:Hide();
        return;
    end
    local list = objSwf.list;
    list.dataProvider:cleanUp();
    for i = 1, len do
        list.dataProvider:push( self.operList[i].name );
    end
    list.height = len * 20 + 10;
    objSwf.bg.height = len * 20 + 10;
    list:invalidateData();
end

--获取左键菜单列表
function UIDealOper:GetOperList(pos)
    local list = {};
    local item = DealModel:GetMyItem(pos);
    if item and item.hasItem then
        for i, oper in pairs( DealConsts.AllOper ) do
            if self:CheckHasOperRights(oper, item) then
                local data = {};
                data.name = DealConsts:GetOperName(oper);
                data.oper = oper;
                table.push( list, data );
            end
        end
    end
    return list;
end

--查看物品是否可以显示这个菜单功能
function UIDealOper:CheckHasOperRights(oper, goods)
    if oper == DealConsts.MOper_OffShelves then
        return true;
    end
end

--点击列表
function UIDealOper:OnListItemClick(e)
    self:Hide();
    local operData = self.operList[e.index + 1];
    if not operData then return end
    if operData.oper == DealConsts.MOper_OffShelves then
        DealController:PullOffShelves( self.pos );
    end
end

--点击其他地方,关闭
function UIDealOper:HandleNotification(name,body)
    local objSwf = self.objSwf;
    if not objSwf then return; end
    if name == NotifyConsts.StageClick then
		if not self.slotMc then
			self:Hide();
			return;
		end
        local slotTarget = string.gsub(self.slotMc._target,"/",".");
        local listTarget = string.gsub(objSwf._target, "/",".");
        if string.find(body.target,slotTarget) or string.find(body.target,listTarget) then
            return
        end
        self:Hide();
    elseif name == NotifyConsts.StageFocusOut then
        self:Hide();
    end
end

function UIDealOper:ListNotificationInterests()
    return { NotifyConsts.StageClick, NotifyConsts.StageFocusOut };
end
