require "Core.Module.Common.Panel"

local StarBagPanel = class("StarBagPanel",Panel);
function StarBagPanel:New()
	self = { };
	setmetatable(self, { __index =StarBagPanel });
	return self
end


function StarBagPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function StarBagPanel:_InitReference()
	self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNum");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollView/phalanx");
	self._phalanx = Phalanx:New();
    local Item = require "Core.Module.Star.View.StarItem2"
	self._phalanx:Init(self._phalanxInfo, Item)
end

function StarBagPanel:_InitListener()
	self:_AddBtnListen(self._btn_close.gameObject)
end

function StarBagPanel:_OnBtnsClick(go)
	if go == self._btn_close.gameObject  then
		self:_OnClickBtn_close()
	end
end

function StarBagPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(StarNotes.CLOSE_STAR_BAG_PANEL)
end

function StarBagPanel:SetData(data)
    self.data = data
    local d = {}
    table.AddRange(d, StarManager.bag)
    if data then
        local kind = data.kind
        local quality = data.quality
        local eq =  StarManager.equip
        local equipKinds = {}
        for i = #eq, 1, -1 do table.insert(equipKinds, eq[i].kind) end
        for i = #d, 1, -1 do
            local it = d[i]
            local itk = it.kind
            if itk == StarManager.STAR_ELITE_TYPE then -- 星命精华
                 table.remove(d, i)
            elseif table.contains(equipKinds, itk) then
                local diffKind = itk ~= kind --不能选已装备类型的
                it.tempSelected = diffKind
                it.tempTips = (not diffKind) and it.quality > quality
            else
                it.tempSelected = false
                it.tempTips = false
            end
        end
    else
        for i = #d, 1, -1 do 
            local it = d[i]
            it.tempSelected = false
            it.tempTips = false
        end
    end
    table.sort(d, function(a, b)
        if a.tempTips ~= b.tempTips then  return a.tempTips end
        if a.tempSelected ~= b.tempSelected then  return b.tempSelected end
        if a.quality ~= b.quality then  return a.quality > b.quality end
        return a.id < b.id
    end)
	self._phalanx:Build(StarManager.STAR_BAG_MAX / 2, 2, d)
	self:InitItems()
    local n = #d
    self._txtNum.text = n .. '/' .. StarManager.STAR_BAG_MAX
end

function StarBagPanel:InitItems()
    local its = self._phalanx:GetItems()
    for i = #its, 1, -1 do
        local it = its[i].itemLogic
        --Warning(it.data.id .. '' .. tostring(StarManager.GetDataById(it.data.id)))
        it:SetSelect(it.data.tempSelected)
        it:SetTips(it.data.tempTips)
        it.ctroller = self
    end
end

function StarBagPanel:SelectItem(item)
    --Warning(tostring(self.data).. '' .. tostring(item:GetSelect()))
    if item:GetSelect() then return end
    if not self.data then return end
    StarProxy.SendChange(self.data.idx, item.data.id, self.data.id)
    self:_OnClickBtn_close()
end

function StarBagPanel:_Dispose()
	self:_DisposeReference();
    self._phalanx:Dispose()
	self._phalanx = nil
end

function StarBagPanel:_DisposeReference()
	self._btn_close = nil;
	self._txtNum = nil;
end
return StarBagPanel