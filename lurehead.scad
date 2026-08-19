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

// Eye pocket geometry (flat-bottom recesses)
eye_diameter      = 10.25;
eye_depth         = 2.5;
eye_z             = 43;

// Extension tube with integrated ramps (profile-driven)
extension_length  = 25;    // Total extension length
tube_od           = 23;    // Baseline diameter
tube_id           = 22;    // Inner bore diameter (through center)
ramp_peak_d       = 25;    // Peak diameter of ramp sections

ramp1_length      = 12;
ramp_gap          = 1;
ramp2_length      = 12;

// Axial position where the sinker cavity ends (distance from nose)
cavity_end        = 18;
// Axial position where the front taper begins
transition_start  = 8;


// -----------------------------
// EXTERIOR PROFILE
// x = axial distance from nose
// r = outside radius
// Maintains 28mm max diameter to rear (no taper)
// Hard edge at rear where extension begins
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

            // smooth monotonic shoulder to eliminate ring seam
            [12.6,24.0],
            [13.0,26.0],
            [13.3,28.0],
            [13.55,30.0],
            [13.75,32.0],
            [13.9,34.0],
            [14.0,37.0],

            // hold 28 mm OD through rear of main head
            [14.0,45.0],
            [14.0,51.0],
            [14.0,56.0],
            [14.0,59.5],
            [14.0,62.0],
            [0,62.0]
        ]);
}


// -----------------------------
// INTEGRATED SKIRT TUBE PROFILE
// (tube itself forms the two ramp/peak sections)
// -----------------------------
module extension_with_ramps()
{
    z0 = head_length;
    z1 = z0 + ramp1_length;              // end section 1
    z2 = z1 + ramp_gap;                  // end gap
    z3 = z2 + ramp2_length;              // end section 2

    r_base = tube_od/2;                  // 11.5
    r_peak = ramp_peak_d/2;              // 12.5

    // Piecewise profile in (radius, axial-z)
    rotate_extrude()
        polygon([
            [0, z0],
            [r_base, z0],
            [r_peak, z1],   // ramp up over first 12 mm
            [r_base, z2],   // ramp down across 1 mm gap
            [r_peak, z3],   // ramp up over second 12 mm
            [0, z3]
        ]);
}


// Flat-bottom eye pockets (cylindrical counterbores, mirrored left/right)
module eye_pockets()
{
    for (side = [-1, 1])
        translate([side*(max_diameter/2 - eye_depth), 0, eye_z])
            rotate([0,90,0])
                // long cutter guarantees subtraction intersection
                cylinder(d=eye_diameter, h=max_diameter*2, center=true);
}


// Central bore through extension
module central_bore()
{
    translate([
        0,
        0,
        head_length - 1
    ])
        cylinder(
            d=tube_id,
            h=extension_length + 2
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
        extension_with_ramps();
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
    cavity_start = head_length + extension_length;

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
            h=head_length + extension_length + 2
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

    // Eye pockets
    eye_pockets();

    // Central bore for egg weight insertion
    central_bore();

    // Large egg-sinker cavity
    sinker_cavity();

    // Forward tapered transition
    cavity_transition();

    // Continuous leader bore
    leader_passage();
}
