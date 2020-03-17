--[[
主界面属性飘字
lizhuangzhuang
2015年1月22日17:24:21
]]

_G.UIMainAttr = BaseUI:new("UIMainAttr");

--需要显示属性变化
UIMainAttr.ShowChangeMap = {
	enAttrType.eaHunLi,enAttrType.eaTiPo,enAttrType.eaShenFa,enAttrType.eaJingShen,
	enAttrType.eaMaxHp,enAttrType.eaMaxMp,
	enAttrType.eaGongJi,enAttrType.eaFangYu,enAttrType.eaMingZhong,enAttrType.eaShanBi,enAttrType.eaBaoJi,enAttrType.eaRenXing,
	enAttrType.eaMoveSpeed,
	enAttrType.eaBaoJiHurt,enAttrType.eaBaoJiDefense,
	enAttrType.eaChuanCiHurt,enAttrType.eaGeDang,enAttrType.eaHurtAdd,enAttrType.eaHurtSub,
	--@reason 新增加的属性 adder:hoxuduong date:2016/7/9
	--@param  需要flash里面增加关键帧支持
	enAttrType.eaDefJianSu,enAttrType.eaDefXuanYun,enAttrType.eaDefChenMo,enAttrType.eaDefDingShen,enAttrType.eaDefYuLiu
};

--冷却时间
UIMainAttr.coolDownTime = 0;
UIMainAttr.list = {};

function UIMainAttr:Create()
	self:AddSWF("mainPageAttr.swf",true,"float");
end

function UIMainAttr:OnLoaded(objSwf)

end

function UIMainAttr:NeverDeleteWhenHide()
	return true;
end

--显示属性变化
function UIMainAttr:ShowAttrChange(type,val)
	if not self.bShowState then return; end
	if val == 0 then return; end
	for i,v in ipairs(self.ShowChangeMap) do
		if v == type then
			table.push(self.list,{type=type,val=val});
			break;
		end
	end
end

function UIMainAttr:ShowFloatAttr(vo)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local depth = objSwf:getNextHighestDepth();
	local mc = objSwf:attachMovie("AttrChange",self:GetMcName(),depth);
	mc:gotoAndStop(1);
	mc._visible = false;
	mc.playOver = function(e)
		mc.playOver = nil;
		mc:removeMovieClip();
		mc = nil;
	end
	local func = function()
		if vo.val >= 0 then
			mc.mc.mcAttr:gotoAndStop("attr"..vo.type);
		else
			mc.mc.mcAttr:gotoAndStop("attr-"..vo.type);
		end
		if vo.val >= 0 then
			mc.mc.numLoader.prefix = "attr+";
		else
			mc.mc.numLoader.prefix = "attr-";
		end
		--四字
		if vo.type==enAttrType.eaMoveSpeed or vo.type==enAttrType.eaHurtAdd or vo.type==enAttrType.eaHurtSub then
			mc.mc.numLoader._x = 44;
		else
			mc.mc.numLoader._x = 22;
		end
		mc.mc.numLoader.num = vo.val;
		mc._visible = true;
		mc:play();
	end
	--
	if mc.initialized then
		func();
	else
		mc.init = function()
			func();
		end
	end
end

function UIMainAttr:Update(dwInterval)
	if not self.bShowState then return; end
	if self.coolDownTime <=0 then
		if #self.list > 0 then
			local vo = table.remove(self.list,1);
			self:ShowFloatAttr(vo);
			self.coolDownTime = 300;
		end
	else
		self.coolDownTime = self.coolDownTime - dwInterval;
	end
end

UIMainAttr.mcIndex = 0;
function UIMainAttr:GetMcName()
	self.mcIndex = self.mcIndex + 1;
	return self.mcIndex;
end