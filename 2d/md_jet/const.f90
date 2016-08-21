module const

  implicit none

! physical constants
  real(8),parameter :: pi = acos(-1.0d0), pi2 = 2d0*pi
  real(8),parameter :: gm = 5d0/3d0 ! specific heat retio

! time control parameters
  logical,parameter :: restart = .false. ! if .true. then start from restart data
  integer,parameter :: nstop = 100000
  real(8),parameter :: tend = 10.0d0, dtout = 1
  real(8),parameter :: dtmin = 1d-10! minimum time step
  real(8),parameter :: safety = 0.3d0 ! CFL number
  character(*),parameter :: input_dir = "./data/", output_dir = "./data/"

! Cell & MPI
  integer,parameter :: margin = 3 ! for 5th order interpolation
  integer,parameter :: ix = 63+2*margin,jx=80+2*margin
  integer,parameter :: mpisize_x = 2, mpisize_y = 2
  integer,parameter :: igx = ix*mpisize_x-2*margin*(mpisize_x-1)
  integer,parameter :: jgx = jx*mpisize_y-2*margin*(mpisize_y-1)
  real(8),parameter :: xmin = 0.d0, ymin = 0.d0
  real(8),parameter :: xmax = 10d0, ymax = 30.d0
  real(8),parameter :: dxg0 = (xmax-xmin)/real(igx-margin*2)
  real(8),parameter :: dyg0 = (ymax-ymin)/real(jgx-margin*2)
  !TRUE if periodic boundary condition is applied. (1:x, 2:y, 3:z)
  logical,parameter :: pbcheck(2) = (/.false., .false./)

! jet parameter
  integer,parameter :: FLAG_Accuracy=0
  real(8),parameter :: ro_jet = 0.1d0
  real(8),parameter :: pr_jet = 1d0/gm
  real(8),parameter :: vx_jet = 0d0
  real(8),parameter :: vy_jet = 19d0
  real(8),parameter :: vz_jet = 1d0
  real(8),parameter :: bx_jet = 0d0
  real(8),parameter :: by_jet = sqrt(2d0*pr_jet*1d-2)
  real(8),parameter :: bz_jet = 0d0
  real(8),parameter :: r_jet = 1d0
  real(8),parameter :: eta0 = 0d0, vc = 0d0

! gravity
  real(8),parameter :: grav = 0d0, ssg = 0.1d0, sseps = 0.2d0
  real(8),parameter :: xin = 0.2d0

! ambient parameter
  real(8),parameter :: ro_am = 1d0
  real(8),parameter :: pr_am = 1d0/gm
  real(8),parameter :: vx_am = 0d0
  real(8),parameter :: vy_am = 0d0
  real(8),parameter :: vz_am = 0d0
  real(8),parameter :: bx_am = 0d0
  real(8),parameter :: by_am = sqrt(2d0*pr_jet*1d-2)
  real(8),parameter :: bz_am = 0d0


end module const
