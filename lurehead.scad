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

// Rear skirt spigot
spigot_base_d     = 17.5;
spigot_peak_d     = 21.5;

ramp1_length      = 12;
ramp_gap          = 1;
ramp2_length      = 12;

spigot_length = ramp1_length + ramp_gap + ramp2_length;

// Axial position where the sinker cavity ends (distance from nose)
cavity_end        = 18;
// Axial position where the front taper begins
transition_start  = 8;

// Skirt collar dimensions
collar_od         = 25;    // Outer diameter of collar
collar_height     = 3.0;   // Height/thickness of collar
collar_position   = head_length - 2;  // Position on the head body


// -----------------------------
// EXTERIOR PROFILE
// x = axial distance from nose
// r = outside radius
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
            [10.8,62.0],
            [0,62.0]
        ]);
}


// -----------------------------
// SKIRT COLLAR
//
// Decorative/functional ring at the
// base of the lure head where it meets
// the spigot.
// -----------------------------
module skirt_collar()
{
    translate([
        0,
        0,
        collar_position
    ])
    {
        // Main collar ring
        cylinder(
            d=collar_od,
            h=collar_height,
            center=true
        );
    }
}


// -----------------------------
// RAMPED SKIRT SPIGOT
// -----------------------------
module skirt_ramp(len)
{
    rotate_extrude()
        polygon([
            [0,0],
            [spigot_base_d/2,0],
            [spigot_peak_d/2,len],
            [0,len]
        ]);
}


module skirt_spigot()
{
    // Base support
    cylinder(
        d=spigot_base_d,
        h=spigot_length
    );

    // First 12 mm ramp
    skirt_ramp(ramp1_length);

    // 1 mm separation
    translate([
        0,
        0,
        ramp1_length + ramp_gap
    ])
        skirt_ramp(ramp2_length);
}


// -----------------------------
// EXTERIOR BODY
// -----------------------------
module exterior()
{
    union()
    {
        head_profile();

        translate([
            0,
            0,
            head_length
        ])
            skirt_spigot();
        
        // Add skirt collar
        skirt_collar();
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
    cavity_start = head_length + spigot_length;

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
            h=head_length + spigot_length + 2
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

    // Large egg-sinker cavity
    sinker_cavity();

    // Forward tapered transition
    cavity_transition();

    // Continuous leader bore
    leader_passage();
}
