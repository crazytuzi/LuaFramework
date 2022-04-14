--
-- @Author: chk
-- @Date:   2018-08-28 11:39:15
--
ScrollViewUtil = ScrollViewUtil or {}

--scrollViewTra  ScrollView的transform
--cellParent     格子要挂载的父节点
--cellSize       格子的大小
--cellClass      操作格子的类
--begPos         第一个格子在scroll view中的开始位置
--spanX          x轴间隙
--spanY          y轴间隙
--createCellCB   创建格子的回调
--updateCellCB   更新格子的回调
--cellCount      总共要创建的格子数
function ScrollViewUtil.CreateItems(param)
	local scrollRect = param["scrollViewTra"]:GetComponent('ScrollRect')
	local cellParent = param["cellParent"]
	local contentRectTra = nil
	if cellParent  then
		contentRectTra = cellParent:GetComponent('RectTransform')
	end

	local _param = {}
	_param["begIdx"] =  param["begIdx"]
	_param["begPos"] = param["begPos"]                                      --第一个格子在scroll view中的开始位置
	_param["cellClass"] = param["cellClass"]                                --初始cell信息的类
	_param["scrollRect"] = scrollRect                                       --scroll Rect 脚本
	_param["contenRectTra"] = contentRectTra                                --scroll view 的content的 RectTransform 脚本
	_param["cellParent"] = cellParent                                       --cell的父节点
	_param["instanceObj"] =param["instanceObj"]
	_param["cellSize"] = param["cellSize"]                                  --格子的尺寸Vector2类型 
	_param["spanX"] = param["spanX"]                                        --x轴间隙
	_param["spanY"] = param["spanY"]                                        --y轴间隙
	_param["createCellCB"] = param["createCellCB"]                          --创建格子的回调
	_param["updateCellCB"] = param["updateCellCB"]                          --更新格子的回调
	_param["cellCount"] = param["cellCount"]
    _param["totalColumn"] = param["totalColumn"];
	_param["totalRow"] = param["totalRow"];
	if param.gameObject then
		_param.gameObject = param.gameObject
	end
	local scrollView = ScrollView(_param)

	return scrollView
end
