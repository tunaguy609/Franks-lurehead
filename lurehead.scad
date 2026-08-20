// GREEN MACHINE STYLE OFFSHORE TROLLING LURE HEAD
// 30 mm maximum OD  |  22 mm sinker cavity
// Includes 25 mm skirt tube extension at rear.
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

// Skirt tube
tube_length       = 25;     // total skirt tube length
tube_od           = 23;     // base tube OD
ramp_length       = 12;     // first section length with OD ramp/bulge
ramp_peak_od      = 24.5;   // peak OD in ramp section
ramp_gap          = 1.0;    // 1mm gap between ramp peak and straight tube

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

// -----------------------------
// Skirt tube profile (attached at head rear)
// - Starts at z = head_length
// - 25 mm total length
// - First section: ramp with hard edges, peaking at 24.5 mm OD
// - 1 mm gap at peak
// - Last section: constant 23 mm OD tube
// -----------------------------
module skirt_tube_profile()
{
    z0 = head_length;
    z1 = z0 + ramp_length/2;           // peak station
    z2 = z0 + ramp_length;             // end of ramp section
    z3 = z2 + ramp_gap;                // start of straight tube after gap
    z4 = z0 + tube_length;             // tube end

    r_base = tube_od / 2;
    r_peak = ramp_peak_od / 2;

    rotate_extrude()
        polygon([
            [0.0,    z0],
            [r_base, z0],
            [r_peak, z1],   // peak OD at midpoint — hard edge
            [r_peak, z1],   // hard edge duplicate to maintain sharpness
            [r_base, z2],   // returns to base OD by 12 mm — hard edge down
            [r_base, z3],   // gap of 1 mm
            [r_base, z4],   // straight tube continues to end
            [0.0,    z4]
        ]);
}


// Combined exterior solid
module exterior()
{
    union() {
        head_profile();
        skirt_tube_profile();
    }
}


// ============================================================
// INTERNAL CUTS
// ============================================================

// -----------------------------
// Leader passage — continuous 2.5 mm bore from nose through tube end.
// Extended by 1 mm past each end to guarantee clean cuts.
// -----------------------------
module leader_passage()
{
    total_length = head_length + tube_length;
    translate([0, 0, -1])
        cylinder(d=leader_bore, h=total_length + 2);
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
// Runs from cavity_end (18 mm from nose) through head and tube end.
// Extended by 1 mm past the rear to guarantee a clean cut.
// -----------------------------
module sinker_cavity()
{
    total_length = head_length + tube_length;
    translate([0, 0, cavity_end])
        cylinder(d=sinker_bore, h=total_length - cavity_end + 1);
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
    sinker_cavity();        // 21.5 mm egg-sinker void through tube
    eye_pockets();          // side recesses for doll eyes
}
