TestSeq = class("TestSeq",SequenceContent);

function TestSeq.GetSteps()
    return {
        TestSeq.A,
        TestSeq.B,
        TestSeq.C,
        TestSeq.D
    };
end

function TestSeq.A(seq)
    log("TestSeq.A ");
    return SequenceCommand.Delay(1.0);
end

function TestSeq.B(seq)
    log("TestSeq.B ");
    return SequenceCommand.DelayFrame();
end

function TestSeq.C(seq)
    log("TestSeq.C ");
    return nil;
end

function TestSeq.D(seq)
    log(seq);
    return SequenceCommand.WaitForEvent(SequenceEventType.NONE);
end
