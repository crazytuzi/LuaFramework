DecompositionConst = {}

DecompositionConst.Decomposition=1
DecompositionConst.Refined =2

DecompositionConst.UpdateItems = "0" --分解后更新Item
DecompositionConst.SelectItem = "1" --选中分解某个Item进行分解
DecompositionConst.UnselectItem = "2" --取消选中分解某个Item进行分解

DecompositionConst.Succ = "3"
-- DecompositionConst.AutoSucc = "5"

DecompositionConst.CancelItem = "9" --取消分解某个Item

DecompositionConst.MaxSelectItemsCnt = 4 --最大可选中的

DecompositionConst.RareIndex =
{
	None = 0,
	White = 1, --白色品階
	Green = 2, --綠色
	Blue = 3, --藍色
}

DecompositionConst.TipsContent1 = {
	[1] = "依分解装备品质，可得不同等级注灵石",
	[2] = "一键分解会将勾选品质的装备全数分解"
}
DecompositionConst.TipsContent2 = {
	[1] = "依提炼装备品质，可得不同等级神兽精华",
	[2] = "一键提炼会将勾选品质的装备全数提炼"
}