--[[
    tap按钮管理管理类

    --By: haidong.gan
    --2013/11/11
]]

--[[
--用法举例

    local dic = {[1] = map_btn, [2] = map_btn};
    local GroupButtonManager = GroupButtonManager:new(dic);
]]


local GroupButtonManager = class("GroupButtonManager");

function GroupButtonManager:ctor(btnDic)
	self.btnDic = btnDic;
    self.curBtn = nil;

    for index,btn in pairs(self.btnDic) do
       btn:setBright(true);
    end

    self:selectIndex(1);
end


function GroupButtonManager:selectBtn(btn)
    if not btn then
      print("btn must be not nil")
      return;
    end 

    if self.curBtn then
       self:setSelect(self.curBtn,false);
    end
    self:setSelect(btn,true);
    self.curBtn = btn;
end


function GroupButtonManager:setSelect(btn,isSelect)
    btn:setBright(not isSelect);
    if btn.effect then
        btn.effect:setVisible(isSelect)
    end
end

function GroupButtonManager:selectIndex(index)
    local btn = self.btnDic[index];
    self:selectBtn(btn);
end

function GroupButtonManager:getSelectButton()
    return self.curBtn;
end

function GroupButtonManager:getSelectIndex()
    for index,btn in pairs(self.btnDic) do
        if btn == self.curBtn then
            return index;
        end
    end
end

function GroupButtonManager:dispose()
    self.btnDic = nil;
    self.curBtn = nil;
end

return GroupButtonManager;