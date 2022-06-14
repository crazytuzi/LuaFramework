limitedActivityNull = class("limitedActivityNull", limitedActivityBase);

function limitedActivityNull:isTaskComplete()
	return false;
end

function limitedActivityNull:shouldShow()
	return false;
end


