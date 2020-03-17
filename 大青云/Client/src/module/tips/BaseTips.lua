--[[
Tips解析基类
lizhuangzhuang
2014年7月24日21:11:40
]]

_G.BaseTips = {};

function BaseTips:new()
	local obj = {};
	for i,v in pairs(self) do
		if type(v) == "function" then
			obj[i] = v;
		end
	end
	obj.str = "";
	self:Init();
	return obj;
end

--初始化
function BaseTips:Init()
end

--解析函数,子类实现
function BaseTips:Parse(tipsInfo)
end

--获取文本内容
function BaseTips:GetStr()
	return self.str;
end

--获取是否显示Icon
function BaseTips:GetShowIcon()
	return true;
end

--获取Icon URL
function BaseTips:GetIconUrl()
	return nil;
end

--获取图标位置
function BaseTips:GetIconPos()
	return {x=0,y=0};
end

--获取是否显示已装备
function BaseTips:GetShowEquiped()
	return false;
end

--获取是否显示标识
function BaseTips:GetShowBiao()
	return "";
end

--道具图标上的等阶图标
function BaseTips:GetIconLevelUrl()
	return "";
end

--获取品质
function BaseTips:GetQualityUrl()
	return "";
end

function BaseTips:GetQuality()
	return -1;
end

--装备卓越星级
function BaseTips:GetSuperStar()
	return 0;
end

--获取Tips特效
function BaseTips:GetTipsEffectUrl()
	return "";
end

--获取Tips的宽
function BaseTips:GetWidth()
	return 320;
end

--获取在Tips上画模型的接口类
function BaseTips:GetModelDrawClz()
	return nil;
end

--画模型的实例类
function BaseTips:GetModelDraw()
	return nil;
end

--获取画模型需要的参数
function BaseTips:GetModelDrawArgs()
	return nil;
end

--adder:houxudong date:2016/8/15 23:56:26
--获取tips显示类型
function BaseTips:GetTipsType(  )
	return 0;
end

function BaseTips:GetRelicIcon()
	return nil
end

--调试信息
function BaseTips:GetDebugInfo()
	return nil;
end

function BaseTips:GetItemID()
	return 0
end

--------------------------以下是父类提供的一些Tips常用方法------------------------
--获取一个竖向的间隙
function BaseTips:GetVGap(gap)
	return "<p><img height='" .. gap .. "' align='baseline' vspace='0'/></p>";
end

--获取Html文本
--@param text 显示的内容
--@param color 字体颜色
--@param size 字号
--@param withBr 是否换行,默认true
--@param bold 	是否加粗,默认false
function BaseTips:GetHtmlText(text,color,size,withBr,bold)
	if not color then color = TipsConsts.Default_Color; end
	if not size then size = TipsConsts.Default_Size; end
	if withBr==nil then withBr = true; end
	if bold==nil then bold = false; end
	local str = "<font color='" .. color .."' size='" .. size .. "'>";
	if bold then
		str = str .. "<b>" .. text .. "</b>";
	else
		str = str .. text;
	end
	str = str .. "</font>";
	if withBr then
		str = str .. "<br/>";
	end
	return str;
end

--changer:houxudong date:2016/8/15 
--获取一条线
--@param topGap 线的上间距,默认10
--@param bottomGap 线的下间距,默认取上间距
function BaseTips:GetLine(topGap,bottomGap)
	if not topGap then topGap = 10; end
	if not bottomGap then bottomGap = topGap; end
	--减掉60
	return "<p><img height='".. topGap .."'/></p><p><img width='".. self:GetWidth() - 70 .."' height='1' align='baseline' vspace='".. bottomGap .."' src='" .. ResUtil:GetTipsLineUrl() .."'/></br></p>"
end

function BaseTips:GetLine2()
	--if not topGap then topGap = 0; end
	local topGap = 0
	return "<p><img height='".. topGap .."'/></p><p><img width='200' height='1' align='baseline' vspace='".. 20 .."' src='" .. ResUtil:GetTipsLineUrl() .."'/></br></p>"
end

--获取星星  --changer:houxudong date:2016/7/18 reason:控制星星间的间距
function BaseTips:GetStar(num, nValue)
	local str = "<p>";
	if num <= EquipConsts.StrenMaxStar then
		for i=1,EquipConsts.StrenMaxStar do
			if i<=num then
				str = str .. "<img width='27' height='27' src='" .. ResUtil:GetTipsStarUrl() .. "'/>".."";
			else
				str = str .. "<img width='27' height='27' src='" .. ResUtil:GetTipsGrayStarUrl() .."'/>".."";
			end
		end
	elseif num <= 24 then
		nValue = nValue and nValue + num or EquipConsts.StrenMaxLvl
		for i=EquipConsts.StrenMaxStar+1,nValue do
			if i<=num then
				str = str .. "<img width='17' height='17' src='" .. ResUtil:GetTipsMoonUrl() .. "'/>".." ";
			else
				str = str .. "<img width='17' height='17' src='" .. ResUtil:GetTipsGrayMoonUrl() .. "'/>".." ";
			end
		end
	else
		for i=25, 36 do
			if i<=num then
				str = str .. "<img width='27' height='27' src='" .. ResUtil:GetTipsSunUrl() .. "'/>".."";
			else
				str = str .. "<img width='27' height='27' src='" .. ResUtil:GetTipsGraySunUrl() .."'/>".."";
			end
		end
	end
	str = str .. "</p>";
	return str;	
end

--设置左边距
function BaseTips:SetLeftMargin(text,margin)
	return "<textformat leftmargin='".. margin .."'>" .. text .. "</textformat>";
end

--设置行间距
--要给一段文字设置行间距,这段文字的最后不应该有换行
function BaseTips:SetLineSpace(text,lineSpace)
	return "<textformat leading='".. lineSpace .."'>" .. text .. "</textformat>";
end
