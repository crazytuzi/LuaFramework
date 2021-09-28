--自动走到某个位置
TodoGoToNpc = class("TodoGoToNpc", SequenceContent)

function TodoGoToNpc.GetSteps()
    return {
        TodoGoToNpc.A
        ,TodoGoToNpc.B
    };
end

function TodoGoToNpc.A(seq)
	--开始走到某个指定位置.
	local todo = seq.param;
	return SequenceCommand.Common.GoToPos(todo.data.mapId, todo.data.pos);
end

function TodoGoToNpc.B(seq)
	--走到位置以后.
	local todo = seq.param;
	if todo.onComplete then
		todo.onComplete();
	end
	return nil;
end

