// GREEN MACHINE STYLE OFFSHORE TROLLING LURE HEAD
// 30 mm maximum OD  |  22 mm sinker cavity
// No skirt collar/ridge — rear is flat/closed at the main head.
//
// Print orientation: nose down (+Z toward rear / open cavity end).
// All dimensions in millimeters.
// Lure axis is the Z axis; nose is at Z = 0.
//

$fn = 128;

// -----------------------------
// KEY DIMENSIONS
// -----------------------------
head_length       = 57;     // nose-to-rear of main head
max_diameter      = 30;     // maximum OD of head
leader_bore       = 2.5;    // through-hole for leader wire

min_wall          = 5.0;
sinker_bore       = 21.5;   // sinker cavity ID

// Eye pockets: flat-bottom cylindrical recesses on ±Y sides
eye_diameter      = 10.25;
eye_depth         = 2.5;
eye_z             = 43;     // axial station (from nose) to pocket centre

// Internal cavity limits (measured from nose)
cavity_end        = 18;     // forward end of the sinker cavity
transition_start  = 8;      // where the leader bore starts flaring to cavity


// ============================================================
// EXTERIOR GEOMETRY
// ============================================================

// -----------------------------
// Head profile (rotated about Z)
// Points are [radius, z-height] — nose at z=0.
// The profile reaches the full 15 mm radius smoothly and
// then holds that diameter to the rear face at z = head_length.
// -----------------------------
module head_profile()
{
    rotate_extrude()
        polygon([
            [ 0.0,  0.0],
            [ 3.5,  1.5],
            [ 5.6,  4.0],
            [ 7.8,  8.0],
            [10.5, 14.0],
            [13.0, 21.0],
            [14.0, 24.0],
            [14.5, 26.0],
            [14.9, 28.0],
            [15.0, 30.0],
            [15.0, 57.0],   // full 30 mm OD carried to the rear
            [ 0.0, 57.0]    // close polygon at axis
        ]);
}


// Combined exterior solid
module exterior()
{
    head_profile();
}


// ============================================================
// INTERNAL CUTS
// ============================================================

// -----------------------------
// Leader passage — continuous 2.5 mm bore from nose to rear.
// Extended by 1 mm past each end to guarantee clean cuts.
// -----------------------------
module leader_passage()
{
    translate([0, 0, -1])
        cylinder(d=leader_bore, h=head_length + 2);
}


// -----------------------------
// Front cavity transition — tapers from the 2.5 mm leader bore
// up to the sinker cavity over the span
// [transition_start … cavity_end].
// d1 (narrow end) is at the nose side; d2 (wide end) joins the cavity.
// -----------------------------
module cavity_transition()
{
    translate([0, 0, transition_start])
        cylinder(
            d1 = leader_bore,
            d2 = sinker_bore,
            h  = cavity_end - transition_start
        );
}


// -----------------------------
// Sinker cavity — cylindrical void that accepts an egg sinker.
// Runs from cavity_end (18 mm from nose) through to the rear face.
// Extended by 1 mm past the rear to guarantee a clean cut.
// -----------------------------
module sinker_cavity()
{
    translate([0, 0, cavity_end])
        cylinder(d=sinker_bore, h=head_length - cavity_end + 1);
}


// -----------------------------
// Eye pockets — flat-bottom cylindrical recesses on the ±Y sides
// of the head at axial station eye_z.
//
// For each side, rotate so the cylinder points inward (toward the axis),
// then place the open end at the outer surface.  The cylinder height of
// eye_depth + 1 mm guarantees a clean flat bottom at the correct depth.
// -----------------------------
module eye_pockets()
{
    for (side = [-1, 1])
        translate([0, side * max_diameter/2, eye_z])  // outer surface, axial station
            rotate([side * 90, 0, 0])                 // point cylinder inward
                cylinder(d=eye_diameter, h=eye_depth + 1);
}


// ============================================================
// FINAL MODEL
// ============================================================
difference()
{
    exterior();

    leader_passage();       // continuous 2.5 mm through-hole
    cavity_transition();    // flared taper from leader bore to cavity
    sinker_cavity();        // 21.5 mm egg-sinker void from rear
    eye_pockets();          // side recesses for doll eyes
}
