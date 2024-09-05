void InitBlockedArrays() {
    InitBlockToItemArray();
    InitBlockToBlockArray();
}


/* /////////////////////////////////   Blocked BlockToBlock List   ///////////////////////////////// */


string[] blockToBlockBlacklist;

void InitBlockToBlockArray() {

}


/* /////////////////////////////////   Blocked BlockToItems List   ///////////////////////////////// */


string[] blockToItemBlacklist;

void InitBlockToItemArray() {
    // Doesn't crash but can't be converted
    blockToItemBlacklist.InsertLast("RoadIceWithWallDiagRightCheckpointLeft");
    blockToItemBlacklist.InsertLast("RoadIceWithWallDiagRightCheckpointRight");

    // Crashes the game (does not produce an item)
    blockToItemBlacklist.InsertLast("DecoPlatformSlope2Base2CurveOut");
    blockToItemBlacklist.InsertLast("DecoPlatformSlope2Base2CurveIn");
    blockToItemBlacklist.InsertLast("DecoPlatformSlope2Start2Curve2In");
    blockToItemBlacklist.InsertLast("DecoPlatformSlope2Start2Curve4Out");
    blockToItemBlacklist.InsertLast("DecoPlatformSlope2End2Curve2Out");
    blockToItemBlacklist.InsertLast("DecoPlatformSlope2End2Curve4In");
    blockToItemBlacklist.InsertLast("DecoPlatformSlope4Base4CurveOut");
    blockToItemBlacklist.InsertLast("DecoPlatformSlope4Base4CurveIn");
    blockToItemBlacklist.InsertLast("DecoPlatformSlope2Start2Base5");

    blockToItemBlacklist.InsertLast("DecoPlatformDirtSlope2Base2CurveOut");
    blockToItemBlacklist.InsertLast("DecoPlatformDirtSlope2Base2CurveIn");
    blockToItemBlacklist.InsertLast("DecoPlatformDirtSlope2Start2Curve2In");
    blockToItemBlacklist.InsertLast("DecoPlatformDirtSlope2Start2Curve4Out");
    blockToItemBlacklist.InsertLast("DecoPlatformDirtSlope2End2Curve2Out");
    blockToItemBlacklist.InsertLast("DecoPlatformDirtSlope2End2Curve4In");
    blockToItemBlacklist.InsertLast("DecoPlatformDirtSlope4Base4CurveOut");
    blockToItemBlacklist.InsertLast("DecoPlatformDirtSlope4Base4CurveIn");
    blockToItemBlacklist.InsertLast("DecoPlatformDirtSlope2Start2Base5");

    blockToItemBlacklist.InsertLast("DecoPlatformIceSlope2Base2CurveOut");
    blockToItemBlacklist.InsertLast("DecoPlatformIceSlope2Base2CurveIn");
    blockToItemBlacklist.InsertLast("DecoPlatformIceSlope2Start2Curve2In");
    blockToItemBlacklist.InsertLast("DecoPlatformIceSlope2Start2Curve4Out");
    blockToItemBlacklist.InsertLast("DecoPlatformIceSlope2End2Curve2Out");
    blockToItemBlacklist.InsertLast("DecoPlatformIceSlope2End2Curve4In");
    blockToItemBlacklist.InsertLast("DecoPlatformIceSlope4Base4CurveOut");
    blockToItemBlacklist.InsertLast("DecoPlatformIceSlope4Base4CurveIn");
    blockToItemBlacklist.InsertLast("DecoPlatformIceSlope2Start2Base5");

    blockToItemBlacklist.InsertLast("StageDiagIn");

    blockToItemBlacklist.InsertLast("StageCurve1In");
    blockToItemBlacklist.InsertLast("StageCurve2In");
    blockToItemBlacklist.InsertLast("StageCurve3In");
    blockToItemBlacklist.InsertLast("StageCurve1Out");
    blockToItemBlacklist.InsertLast("StageCurve2Out");
    blockToItemBlacklist.InsertLast("StageCurve3Out");
}


/* /////////////////////////////////   Blocked ItemsToItems List   ///////////////////////////////// */

string[] itemToItemBlacklist;

void InitItemToItemArray() {

}