cc = cc or {}
cc.Wrapper = cc.Wrapper or {}

--大部分action都会调用节点的某些接口，比如MoveTo就是每帧调用节点改变坐标的接口，而不同引擎其接口都不一样的，所以为了action们能够通用就增加了此中间层，为你的引擎实现本文件的所有接口就可以了。

function cc.Wrapper.SetLocalPosition( node, x, y, z )
	SetLocalPosition(node, x, y, z)
end

function cc.Wrapper.GetLocalPosition( node )
	return GetLocalPosition(node)
end

function cc.Wrapper.GetGlobalPosition(node)
    return GetGlobalPosition(node)
end

function cc.Wrapper.SetGlobalPosition( node, x, y, z )
    SetGlobalPosition(node, x, y, z)
end

function cc.Wrapper.SetVisible( node, is_show )
	SetVisible(node,is_show)
end

function cc.Wrapper.GetVisible( node )
	return GetVisible(node)
end

function cc.Wrapper.GetLocalScale( node )
	return GetLocalScale(node)
end

function cc.Wrapper.SetLocalScale( node, x, y, z )
	SetLocalScale(node, x, y, z)
end

function cc.Wrapper.GetLocalRotation( node )
	local x,y,z = GetLocalRotation(node)
	return z
end

function cc.Wrapper.SetLocalRotation( node, x, y, z )
	SetLocalRotation(node, x, y, z)
end

-- 只能用于图片 文本等
function cc.Wrapper.GetAlpha( node )
	return GetAlpha(node)
end

function cc.Wrapper.SetAlpha( node, alpha )
	SetAlpha(node, alpha)
end

function cc.Wrapper.GetSize( node )
	return GetSizeDeltaX(node) , GetSizeDeltaY(node);
end

function cc.Wrapper.SetSize( node, w, h )
	SetSizeDelta(node , w , h);
end

function cc.Wrapper.destroy( node )
	if node ~= nil then
		node:destroy()
	end
end