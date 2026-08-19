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

// Extension tube with external ramps
extension_length  = 25;    // Total extension length
tube_od           = 23;    // Outer diameter of tube
tube_id           = 22;    // Inner bore diameter (through center)
ramp_peak_d       = 25;    // Peak diameter of ramps

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
    // rotate_extrude expects points as [radius, z]
    // (not [z, radius])
    rotate_extrude()
        polygon([
            [0,0],        // tip on axis
            [1.5,3.2],
            [4.0,5.0],
            [8.0,7.0],
            [14.0,9.5],
            [21.0,11.8],
            [29.0,13.4],
            [37.0,14.0],
            [45.0,14.0],
            [51.0,13.6],
            [56.0,12.8],
            [59.5,12.8],
            [62.0,14.0],  // rear OD = 28 mm
            [62.0,0]      // close at axis
        ]);
}


// -----------------------------
// EXTERNAL RAMP
//
// Ramped shoulder that flares outward for skirt attachment.
// Ramps from 23mm to 25mm diameter.
// Skirts rest on this angled flaring surface.
// -----------------------------
module external_ramp(len)
{
    rotate_extrude()
        polygon([
            [tube_od/2, 0],
            [ramp_peak_d/2, 0],
            [ramp_peak_d/2, len],
            [tube_od/2, len]
        ]);
}


// -----------------------------
// EXTENSION TUBE WITH RAMPS
//
// 25mm long tube (23mm OD, 22mm ID) with
// two external flaring ramps:
// - 0-12mm: First ramp (23mm to 25mm)
// - 12-13mm: Flat gap (23mm tube only)
// - 13-25mm: Second ramp (23mm to 25mm)
// Ramps flare outward where skirts rest.
// Directly attached to head profile (no collar).
// -----------------------------
module extension_with_ramps()
{
    // Curved shoulder blend (28 mm head -> 23 mm tube)
    blend_len = 2.2;          // axial length of blend
    mid_z     = 0.55*blend_len;
    mid_d     = tube_od + 0.62*(max_diameter - tube_od);

    // Smooth transition using hull of very thin rings
    hull()
    {
        translate([0,0,head_length - blend_len])
            cylinder(d=max_diameter, h=0.01);

        translate([0,0,head_length - blend_len + mid_z])
            cylinder(d=mid_d, h=0.01);

        translate([0,0,head_length])
            cylinder(d=tube_od, h=0.01);
    }

    translate([
        0,
        0,
        head_length
    ])
    {
        // Base tube (23mm OD, extends full length)
        cylinder(
            d=tube_od,
            h=extension_length
        );

        // First external ramp (0-12 mm, flares to 25mm)
        external_ramp(ramp1_length);

        // Second external ramp (13-25 mm, positioned after gap)
        translate([
            0,
            0,
            ramp1_length + ramp_gap
        ])
            external_ramp(ramp2_length);
    }
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

    // Central bore for egg weight insertion
    central_bore();

    // Large egg-sinker cavity
    sinker_cavity();

    // Forward tapered transition
    cavity_transition();

    // Continuous leader bore
    leader_passage();
}
