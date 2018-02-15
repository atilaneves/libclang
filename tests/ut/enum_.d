module ut.enum_;

import clang.c.index;
import unit_threaded;


@("CXAvailabilityKind")
@safe pure unittest {
    CXAvailabilityKind.CXAvailability_Deprecated.shouldEqual(CXAvailability_Deprecated);
}

@("CXCursor_ExceptionSpecificationKind")
@safe pure unittest {
    CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_Uninstantiated.shouldEqual(CXCursor_ExceptionSpecificationKind_Uninstantiated);
}

@("CXGlobalOptFlags")
@safe pure unittest {
    CXGlobalOptFlags.CXGlobalOpt_ThreadBackgroundPriorityForEditing.shouldEqual(CXGlobalOpt_ThreadBackgroundPriorityForEditing);
}

@("CXDiagnosticSeverity")
@safe pure unittest {
    CXDiagnosticSeverity.CXDiagnostic_Warning.shouldEqual(CXDiagnostic_Warning);
}
