//
// GREEN MACHINE STYLE OFFSHORE TROLLING LURE HEAD
// 28 mm maximum OD / extended 22 mm sinker cavity
// Double 12 mm ramped skirt spigot with 1 mm gap
//
// All dimensions in millimeters
//

$fn = 128;

// -----------------------------
// PRIMARY DIMENSIONS
// -----------------------------
head_length       = 62;
max_diameter      = 28;
leader_bore       = 2.5;

min_wall          = 3.0;
sinker_bore       = max_diameter - 2*min_wall;  // 22 mm

// Skirt collar and ramps
collar_length     = 23;    // Total collar length
collar_od         = 28;    // Outer diameter matches head
collar_id         = 22;    // Inner bore diameter for egg weight
ramp1_length      = 12;
ramp_gap          = 1;
ramp2_length      = 12;

// Ramp geometry
ramp_base_d       = 17.5;  // Base diameter at collar
ramp_peak_d       = 21.5;  // Peak diameter at ramp tip

// Axial position where the sinker cavity ends (distance from nose)
cavity_end        = 18;
// Axial position where the front taper begins
transition_start  = 8;


// -----------------------------
// EXTERIOR PROFILE
// x = axial distance from nose
// r = outside radius
// Last point kept at 14.0 radius (28mm diameter) for hard edge
// -----------------------------
module head_profile()
{
    rotate_extrude()
        polygon([
            [0,0],
            [3.2,1.5],
            [5.0,4.0],
            [7.0,8.0],
            [9.5,14.0],
            [11.8,21.0],
            [13.4,29.0],
            [14.0,37.0],
            [14.0,45.0],
            [13.6,51.0],
            [12.8,56.0],
            [11.7,59.5],
            [14.0,62.0],
            [0,62.0]
        ]);
}


// -----------------------------
// COLLAR WITH INTEGRATED RAMPS
//
// 23 mm long collar with:
// - 12 mm first ramp
// - 1 mm gap
// - 12 mm second ramp
// - 22 mm ID bore through center
// - 28 mm OD cylinder base
// -----------------------------
module collar_with_ramps()
{
    translate([
        0,
        0,
        head_length
    ])
    {
        // Outer cylinder base (full collar length)
        cylinder(
            d=collar_od,
            h=collar_length
        );
        
        // First ramp (0-12 mm)
        rotate_extrude()
            polygon([
                [0,0],
                [ramp_base_d/2,0],
                [ramp_peak_d/2,ramp1_length],
                [0,ramp1_length]
            ]);
        
        // Second ramp (13-25 mm, but only 12 mm long)
        translate([
            0,
            0,
            ramp1_length + ramp_gap
        ])
        rotate_extrude()
            polygon([
                [0,0],
                [ramp_base_d/2,0],
                [ramp_peak_d/2,ramp2_length],
                [0,ramp2_length]
            ]);
    }
}


// Hollow out the 22mm bore
module collar_bore()
{
    translate([
        0,
        0,
        head_length - 1
    ])
        cylinder(
            d=collar_id,
            h=collar_length + 2
        );
}


// -----------------------------
// EXTERIOR BODY
// -----------------------------
module exterior()
{
    union()
    {
        head_profile();
        collar_with_ramps();
    }
}


// -----------------------------
// INTERNAL SINKER CAVITY
//
// 22 mm cavity enters from the rear
// and extends forward into the head.
//
// The cavity terminates at 18 mm from
// the nose.
// -----------------------------
module sinker_cavity()
{
    cavity_start = head_length + collar_length;

    translate([
        0,
        0,
        cavity_end
    ])
        cylinder(
            d=sinker_bore,
            h=cavity_start-cavity_end
        );
}


// -----------------------------
// LEADER PASSAGE
//
// Continuous 2.5 mm coaxial passage
// through the entire lure.
// -----------------------------
module leader_passage()
{
    translate([
        0,
        0,
        -1
    ])
        cylinder(
            d=leader_bore,
            h=head_length + collar_length + 2
        );
}


// -----------------------------
// FRONT CAVITY TRANSITION
//
// Tapers the internal cavity from
// the 22 mm sinker cavity down to
// the 2.5 mm leader passage.
// -----------------------------
module cavity_transition()
{
    translate([
        0,
        0,
        transition_start
    ])
        cylinder(
            d1=leader_bore,
            d2=sinker_bore,
            h=cavity_end - transition_start
        );
}


// -----------------------------
// FINAL MODEL
// -----------------------------
difference()
{
    exterior();

    // Collar bore for egg weight insertion
    collar_bore();

    // Large egg-sinker cavity
    sinker_cavity();

    // Forward tapered transition
    cavity_transition();

    // Continuous leader bore
    leader_passage();
}
