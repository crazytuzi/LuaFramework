GuideTest = class("GuideTest", SequenceContent)

function GuideTest.GetSteps()
    return {
      	GuideTest.A
      	--,GuideContent.OpenActPanelEnd
      	--,GuideTest.B
      	--,GuideTest.C
    };
end

function GuideTest.A(seq)
	return SequenceCommand.WaitForEvent(SequenceEventType.Base.VEHICLE_INIT);
end

function GuideTest.B(seq)
	return SequenceCommand.Delay(4);
end

function GuideTest.C(seq)
	return nil;
end

