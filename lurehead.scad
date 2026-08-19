//
// GREEN MACHINE STYLE OFFSHORE TROLLING LURE HEAD
// 28 mm maximum OD  |  22 mm sinker cavity
// Single 12 mm ramp + 1 mm return gap + 12 mm straight skirt tube
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
max_diameter      = 28;     // maximum OD of head
leader_bore       = 2.5;    // through-hole for leader wire

min_wall          = 5.0;
sinker_bore       = max_diameter - 2*min_wall;  // 18 mm — egg-sinker cavity ID

// Eye pockets: flat-bottom cylindrical recesses on ±Y sides
eye_diameter      = 10.25;
eye_depth         = 2.5;
eye_z             = 43;     // axial station (from nose) to pocket centre

// Skirt spigot (extension): hollow tube with one ramped ridge,
// then returns to tube OD and continues straight aft.
extension_length  = 25;
tube_od           = 25;     // spigot outer diameter (base / straight section)
tube_id           = 21.5;   // spigot inner bore
ramp_peak_d       = 27;     // outer diameter at ramp peak (must be > tube_od to form visible ramp)

ramp1_length      = 12;     // axial length of first ramp section
ramp_gap          = 1;      // axial return gap from peak back to tube OD
ramp2_length      = 12;     // axial length of straight tube section after gap

// Internal cavity limits (measured from nose)
cavity_end        = 18;     // forward end of the sinker cavity
transition_start  = 8;      // where the leader bore starts flaring to cavity


// ============================================================
// EXTERIOR GEOMETRY
// ============================================================

// -----------------------------
// Head profile (rotated about Z)
// Points are [radius, z-height] — nose at z=0.
// Ogive shoulder widens to 28 mm OD, then holds
// that diameter to the rear face at z = head_length.
// -----------------------------
module head_profile()
{
    rotate_extrude()
        polygon([
            [ 0.0,  0.0],
            [ 3.2,  1.5],
            [ 5.0,  4.0],
            [ 7.0,  8.0],
            [ 9.5, 14.0],
            [11.8, 21.0],
            [12.6, 24.0],   // smooth monotonic shoulder
            [13.0, 26.0],
            [13.3, 28.0],
            [13.55,30.0],
            [13.75,32.0],
            [13.9, 34.0],
            [14.0, 37.0],   // reaches full 28 mm OD here
            [14.0, 57.0],   // hold 28 mm OD to rear face
            [ 0.0, 57.0]    // close polygon at axis
        ]);
}


// -----------------------------
// Skirt spigot with single ramp ridge.
//
// Built as a union of hull() pairs so the solid truly
// extends along the lure axis (rotate_extrude with axial
// coordinates does not produce an axial solid).
//
// The spigot is a hollow tube (central bore removed later).
// Profile:
//   z0 ──(r_base)──> z1 ──(r_peak)
//                               \\──> z2 ──(r_base)──> z3 ──(r_base)
//   Three segments:
//     seg 1: z0→z1  ramp up to ridge peak
//     seg 2: z1→z2  ramp down across 1 mm gap
//     seg 3: z2→z3  straight tube at tube_od (no second ramp)
//
//   z0 = head_length   z1 = z0+ramp1_length
//   z2 = z1+ramp_gap   z3 = z2+ramp2_length
// -----------------------------
module extension_with_ramps()
{
    z0 = head_length;
    z1 = z0 + ramp1_length;
    z2 = z1 + ramp_gap;
    z3 = z2 + ramp2_length;

    r_base = tube_od / 2;      // constant tube radius
    r_peak = ramp_peak_d / 2;  // first ramp peak radius

    union()
    {
        // segment 1: ramp up from tube OD to peak
        hull()
        {
            translate([0, 0, z0]) cylinder(h=0.01, r=r_base);
            translate([0, 0, z1]) cylinder(h=0.01, r=r_peak);
        }

        // segment 2: ramp down from peak back to tube OD across the 1 mm gap
        hull()
        {
            translate([0, 0, z1]) cylinder(h=0.01, r=r_peak);
            translate([0, 0, z2]) cylinder(h=0.01, r=r_base);
        }

        // segment 3: straight tube (no second ramp)
        translate([0, 0, z2])
            cylinder(h=z3 - z2, r=r_base);
    }
}


// Combined exterior solid
module exterior()
{
    union()
    {
        head_profile();
        extension_with_ramps();
    }
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
        cylinder(d=leader_bore, h=head_length + extension_length + 2);
}


// -----------------------------
// Front cavity transition — tapers from the 2.5 mm leader bore
// up to the 18 mm sinker cavity over the span
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
// Sinker cavity — 18 mm cylindrical void that accepts an egg sinker.
// Runs from cavity_end (18 mm from nose) through to the open rear.
// Extended by 1 mm past the rear to guarantee a clean cut.
// -----------------------------
module sinker_cavity()
{
    cavity_rear = head_length + extension_length;

    translate([0, 0, cavity_end])
        cylinder(d=sinker_bore, h=cavity_rear - cavity_end + 1);
}


// -----------------------------
// Central bore through the spigot — removes the core of the
// extension so it is a tube, not a solid rod.
// Includes a short blend at the head/spigot junction so the
// inner transition appears smooth and concentric.
// -----------------------------
module central_bore()
{
    z0 = head_length;
    z1 = z0 + ramp1_length;
    z2 = z1 + ramp_gap;
    z3 = z2 + ramp2_length;

    // Main straight bore through full spigot region
    translate([0, 0, z0 - 1])
        cylinder(d=tube_id, h=(z3 - z0) + 2);

    // Short internal blend from sinker cavity ID to tube ID
    translate([0, 0, z0 - 1.5])
        cylinder(h=1.5, d1=sinker_bore, d2=tube_id);
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
    sinker_cavity();        // 18 mm egg-sinker void from rear
    central_bore();         // hollow core of skirt spigot
    eye_pockets();          // side recesses for doll eyes
}
