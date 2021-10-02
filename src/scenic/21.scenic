#################################
# MAP AND MODEL                 #
#################################

param map = localPath('../maps/carla/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

#################################
# CONSTANTS                     #
#################################

MODEL = 'vehicle.lincoln.mkz2017'

param EGO_INIT_DIST = VerifaiRange(-30, -20)
param EGO_SPEED = VerifaiRange(7, 10)
EGO_BRAKE = 1.0

BIKE_MIN_SPEED = 1.0
BIKE_THRESHOLD = 20

param SAFETY_DIST = VerifaiRange(10, 15)
BUFFER_DIST = 75
CRASH_DIST = 5
TERM_DIST = 50

#################################
# AGENT BEHAVIORS               #
#################################

behavior EgoBehavior():
    try:
        do FollowLaneBehavior(target_speed=globalParameters.EGO_SPEED)
    interrupt when withinDistanceToObjsInLane(self, globalParameters.SAFETY_DIST) and (bike in network.drivableRegion):
        take SetBrakeAction(EGO_BRAKE)
    interrupt when withinDistanceToAnyObjs(self, CRASH_DIST):
        terminate

#################################
# SPATIAL RELATIONS             #
#################################

lane = Uniform(*network.lanes)
spawnPt = OrientedPoint on lane.centerline

#################################
# SCENARIO SPECIFICATION        #
#################################

ego = Car following roadDirection from spawnPt for globalParameters.EGO_INIT_DIST,
    with blueprint MODEL,
    with behavior EgoBehavior()

bike = Bicycle right of spawnPt by 3,
    with heading 90 deg relative to spawnPt.heading,
    with regionContainedIn None,
    with behavior CrossingBehavior(ego, BIKE_MIN_SPEED, BIKE_THRESHOLD)

require (distance to intersection) > BUFFER_DIST
require always (ego.laneSection._slowerLane is None)
require always (ego.laneSection._fasterLane is None)
terminate when (distance to spawnPt) > TERM_DIST
