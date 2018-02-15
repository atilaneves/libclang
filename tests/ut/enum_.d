module ut.enum_;

import clang.c.index;
import unit_threaded;


@("CXAvailabilityKind")
unittest {
    CXAvailabilityKind.CXAvailability_Deprecated.shouldEqual(CXAvailability_Deprecated);
}
