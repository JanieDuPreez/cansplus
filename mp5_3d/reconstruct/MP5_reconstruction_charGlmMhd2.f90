subroutine MP5_reconstruction_charGlmMhd2(mdir,ix,jx,kx,ro,pr &
     ,vx,vy,vz,bx,by,bz,phi &
     ,ch,gm,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw,ccx,ccy,ccz)
  implicit none

  integer,intent(in) :: ix,jx,kx,mdir
  real(8),intent(in) :: gm,ch

  integer,parameter :: nwave = 9

  real(8),dimension(ix,jx,kx),intent(in) :: ro,pr,vx,vy,vz,bx,by,bz,phi
  real(8),dimension(ix,jx,kx,2) :: row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw

  real(8),dimension(5,2,ix),intent(in) :: ccx
  real(8),dimension(5,2,jx),intent(in) :: ccy
  real(8),dimension(5,2,kx),intent(in) :: ccz

  real(8),dimension(nwave) :: wwc_w,qql,qqr
  ! ww(*,1) = qqm2, ..
  real(8),dimension(nwave,5) :: ww,wwc,tmpq
  real(8),dimension(nwave,nwave) :: lem,rem,tmpD1,tmpD2

  real(8) :: wwor
  real(8) :: ro1,pr1,vx1,vy1,vz1,bx1,by1,bz1,phi1

!----parameter
  real(8),parameter :: B1 = 0.016666666667
  real(8),parameter :: B2 = 1.333333333333
  real(8),parameter :: Alpha = 4.0d0
  real(8),parameter :: Epsm = 0.0000000001d0

!----function
  integer :: flag

  integer :: i,j,k,l,m,n

!----function
  real(8) :: minmod4,d1,d2,d3,d4
  real(8) :: minmod,x,y
  real(8) :: median
  
  real(8) :: djm1,dj,djp1,dm4jph,dm4jmh,djpp1,dm4jpph
  real(8) :: qqul,qqav,qqmd,qqlc,qqmin,qqmax,qqmin1,qqmax1
  real(8) :: djp2,qqlr

  minmod4(d1,d2,d3,d4) = 0.125d0*(sign(1.0d0,d1)+sign(1.0d0,d2))* &
       dabs((sign(1.0d0,d1) + sign(1.0d0,d3))* &
       (sign(1.0d0,d1)+sign(1.0d0,d4))) &
       *min(dabs(d1),dabs(d2),dabs(d3),dabs(d4))

  minmod(x,y) = 0.5d0*(sign(1.0d0,x)+sign(1.0d0,y))*min(dabs(x),dabs(y))

  if(mdir .eq. 1)then
     do k=3,kx-2
        do j=3,jx-2
           do i=3,ix-2
              do n=1,5
                 ww(1,n) = ro(i-3+n,j,k)
                 ww(2,n) = vx(i-3+n,j,k)
                 ww(3,n) = vy(i-3+n,j,k)
                 ww(4,n) = vz(i-3+n,j,k)
                 ww(5,n) = pr(i-3+n,j,k)
                 ww(6,n) = bx(i-3+n,j,k)
                 ww(7,n) = by(i-3+n,j,k)
                 ww(8,n) = bz(i-3+n,j,k)
                 ww(9,n) = phi(i-3+n,j,k)
              end do
              ! left state
              
              ! primitive ro characteristic
              
              ro1 = ro(i,j,k)
              pr1 = pr(i,j,k)
              vx1 = vx(i,j,k)
              vy1 = vy(i,j,k)
              vz1 = vz(i,j,k)
              bx1 = bx(i,j,k)
              by1 = by(i,j,k)
              bz1 = bz(i,j,k)
              phi1 = phi(i,j,k)

              call esystem_glmmhd(lem,rem,ro1,pr1,vx1,vy1,vz1,bx1,by1,bz1,phi1,ch,gm)

!!$     do m=1,nwave
!!$        do n=1,nwave
!!$           lem(m,n) = 0.0d0
!!$           rem(m,n) = 0.0d0
!!$           if(m .eq. n)then
!!$              lem(m,n) = 1.0d0
!!$              rem(m,n) = 1.0d0
!!$           end if
!!$        end do
!!$     end do

              do l=1,5
                 do n=1,nwave
                    wwc(n,l) = lem(n,1)*ww(1,l)
                    do m=2,nwave
                       wwc(n,l) = wwc(n,l)+lem(n,m)*ww(m,l)
                    enddo
                 enddo
              end do
              
              ! mp5
              do n=1,nwave
                 wwor = B1*(ccx(1,2,i)*wwc(n,1)+ccx(2,2,i)*wwc(n,2) &
                      + ccx(3,2,i)*wwc(n,3) + ccx(4,2,i)*wwc(n,4) &
                      + ccx(5,2,i)*wwc(n,5))
                 djm1 = wwc(n,1)-2.0d0*wwc(n,2)+wwc(n,3)
                 dj = wwc(n,2)-2.0d0*wwc(n,3)+wwc(n,4)
                 djp1 = wwc(n,3)-2.0d0*wwc(n,4)+wwc(n,5)
                 
                 dm4jph = minmod4(4.0d0*dj-djp1,4.0d0*djp1-dj,dj,djp1)
                 dm4jmh = minmod4(4.0d0*dj-djm1,4.0d0*djm1-dj,dj,djm1)
                 
                 qqul = wwc(n,3)+Alpha*(wwc(n,3)-wwc(n,2))
                 qqlr = wwc(n,4)+Alpha*(wwc(n,4)-wwc(n,5))
                 
                 qqav = 0.5d0*(wwc(n,3)+wwc(n,4))
                 qqmd = qqav - 0.5d0*dm4jph
                 qqlc = wwc(n,3) + 0.5d0*(wwc(n,3)-wwc(n,2)) + B2*dm4jmh
                 
                 qqmin = max(min(wwc(n,3),wwc(n,4),qqmd),min(wwc(n,3),qqul,qqlc))
                 qqmax = min(max(wwc(n,3),wwc(n,4),qqmd),max(wwc(n,3),qqul,qqlc))

                 wwc_w(n) = wwor + minmod((qqmin-wwor),(qqmax-wwor))
              end do
              
              ! characteristic to primitive
              do n=1,nwave
                 qqr(n) = wwc_w(1)*rem(n,1)
                 do m=2,nwave
                    qqr(n) = qqr(n)+wwc_w(m)*rem(n,m)
                 enddo
              enddo
              
              ! right state
              ! mp5
              do n=1,nwave
                 wwor = B1*(ccx(5,1,i-1)*wwc(n,5)+ccx(4,1,i-1)*wwc(n,4) &
                      + ccx(3,1,i-1)*wwc(n,3) + ccx(2,1,i-1)*wwc(n,2) &
                      + ccx(1,1,i-1)*wwc(n,1))

                 djm1 = wwc(n,1)-2.0d0*wwc(n,2)+wwc(n,3)
                 dj = wwc(n,2)-2.0d0*wwc(n,3)+wwc(n,4)
                 djp1 = wwc(n,3)-2.0d0*wwc(n,4)+wwc(n,5)
                 
                 dm4jph = minmod4(4.0d0*dj-djp1,4.0d0*djp1-dj,dj,djp1)
                 dm4jmh = minmod4(4.0d0*dj-djm1,4.0d0*djm1-dj,dj,djm1)
                 
                 qqul = wwc(n,2)+Alpha*(wwc(n,2)-wwc(n,1))
                 qqlr = wwc(n,3)+Alpha*(wwc(n,3)-wwc(n,4))
                 
                 qqav = 0.5d0*(wwc(n,3)+wwc(n,2))
                 qqmd = qqav - 0.5d0*dm4jmh
                 qqlc = wwc(n,3) + 0.5d0*(wwc(n,3)-wwc(n,4)) + B2*dm4jph
                 
                 qqmin = max(min(wwc(n,3),wwc(n,2),qqmd),min(wwc(n,3),qqlr,qqlc))
                 qqmax = min(max(wwc(n,3),wwc(n,2),qqmd),max(wwc(n,3),qqlr,qqlc))
                 
                 wwc_w(n) = wwor + minmod((qqmin-wwor),(qqmax-wwor))
              end do
              
              ! characteristic to primitive
              do n=1,nwave
                 qql(n) = wwc_w(1)*rem(n,1)
                 do m=2,nwave
                    qql(n) = qql(n)+wwc_w(m)*rem(n,m)
                 enddo
              enddo

              qql(1) = max(min(ro(i,j,k),ro(i-1,j,k)),qql(1))
              qql(1) = min(max(ro(i,j,k),ro(i-1,j,k)),qql(1))
              qqr(1) = max(min(ro(i,j,k),ro(i+1,j,k)),qqr(1))
              qqr(1) = min(max(ro(i,j,k),ro(i+1,j,k)),qqr(1))
              
              qql(2) = max(min(vx(i,j,k),vx(i-1,j,k)),qql(2))
              qql(2) = min(max(vx(i,j,k),vx(i-1,j,k)),qql(2))
              qqr(2) = max(min(vx(i,j,k),vx(i+1,j,k)),qqr(2))
              qqr(2) = min(max(vx(i,j,k),vx(i+1,j,k)),qqr(2))
              
              qql(3) = max(min(vy(i,j,k),vy(i-1,j,k)),qql(3))
              qql(3) = min(max(vy(i,j,k),vy(i-1,j,k)),qql(3))
              qqr(3) = max(min(vy(i,j,k),vy(i+1,j,k)),qqr(3))
              qqr(3) = min(max(vy(i,j,k),vy(i+1,j,k)),qqr(3))
              
              qql(4) = max(min(vz(i,j,k),vz(i-1,j,k)),qql(4))
              qql(4) = min(max(vz(i,j,k),vz(i-1,j,k)),qql(4))
              qqr(4) = max(min(vz(i,j,k),vz(i+1,j,k)),qqr(4))
              qqr(4) = min(max(vz(i,j,k),vz(i+1,j,k)),qqr(4))
              
              qql(5) = max(min(pr(i,j,k),pr(i-1,j,k)),qql(5))
              qql(5) = min(max(pr(i,j,k),pr(i-1,j,k)),qql(5))
              qqr(5) = max(min(pr(i,j,k),pr(i+1,j,k)),qqr(5))
              qqr(5) = min(max(pr(i,j,k),pr(i+1,j,k)),qqr(5))
              
              qql(6) = max(min(bx(i,j,k),bx(i-1,j,k)),qql(6))
              qql(6) = min(max(bx(i,j,k),bx(i-1,j,k)),qql(6))
              qqr(6) = max(min(bx(i,j,k),bx(i+1,j,k)),qqr(6))
              qqr(6) = min(max(bx(i,j,k),bx(i+1,j,k)),qqr(6))
              
              qql(7) = max(min(by(i,j,k),by(i-1,j,k)),qql(7))
              qql(7) = min(max(by(i,j,k),by(i-1,j,k)),qql(7))
              qqr(7) = max(min(by(i,j,k),by(i+1,j,k)),qqr(7))
              qqr(7) = min(max(by(i,j,k),by(i+1,j,k)),qqr(7))
              
              qql(8) = max(min(bz(i,j,k),bz(i-1,j,k)),qql(8))
              qql(8) = min(max(bz(i,j,k),bz(i-1,j,k)),qql(8))
              qqr(8) = max(min(bz(i,j,k),bz(i+1,j,k)),qqr(8))
              qqr(8) = min(max(bz(i,j,k),bz(i+1,j,k)),qqr(8))
              
              qql(9) = max(min(phi(i,j,k),phi(i-1,j,k)),qql(9))
              qql(9) = min(max(phi(i,j,k),phi(i-1,j,k)),qql(9))
              qqr(9) = max(min(phi(i,j,k),phi(i+1,j,k)),qqr(9))
              qqr(9) = min(max(phi(i,j,k),phi(i+1,j,k)),qqr(9))
              
              row(i-1,j,k,2) = qql(1)
              row(i,j,k,1) = qqr(1)
              
              vxw(i-1,j,k,2) = qql(2)
              vxw(i,j,k,1) = qqr(2)
              vyw(i-1,j,k,2) = qql(3)
              vyw(i,j,k,1) = qqr(3)
              vzw(i-1,j,k,2) = qql(4)
              vzw(i,j,k,1) = qqr(4)
              
              prw(i-1,j,k,2) = qql(5)
              prw(i,j,k,1) = qqr(5)
              
              bxw(i-1,j,k,2) = qql(6)
              bxw(i,j,k,1) = qqr(6)
              byw(i-1,j,k,2) = qql(7)
              byw(i,j,k,1) = qqr(7)
              bzw(i-1,j,k,2) = qql(8)
              bzw(i,j,k,1) = qqr(8)
              
              phiw(i-1,j,k,2) = qql(9)
              phiw(i,j,k,1) = qqr(9)
           end do
        end do
     end do
  else if(mdir .eq. 2)then
     do k=3,kx-2
        do j=3,jx-2
           do i=3,ix-2
              do n=1,5
                 ww(1,n) = ro(i,j-3+n,k)
                 ww(2,n) = vx(i,j-3+n,k)
                 ww(3,n) = vy(i,j-3+n,k)
                 ww(4,n) = vz(i,j-3+n,k)
                 ww(5,n) = pr(i,j-3+n,k)
                 ww(6,n) = bx(i,j-3+n,k)
                 ww(7,n) = by(i,j-3+n,k)
                 ww(8,n) = bz(i,j-3+n,k)
                 ww(9,n) = phi(i,j-3+n,k)
              end do
              ! left state
              
              ! primitive ro characteristic
              
              ro1 = ro(i,j,k)
              pr1 = pr(i,j,k)
              vx1 = vx(i,j,k)
              vy1 = vy(i,j,k)
              vz1 = vz(i,j,k)
              bx1 = bx(i,j,k)
              by1 = by(i,j,k)
              bz1 = bz(i,j,k)
              phi1 = phi(i,j,k)
              
              call esystem_glmmhd(lem,rem,ro1,pr1,vx1,vy1,vz1,bx1,by1,bz1,phi1,ch,gm)
              
!!$     do m=1,nwave
!!$        do n=1,nwave
!!$           lem(m,n) = 0.0d0
!!$           rem(m,n) = 0.0d0
!!$           if(m .eq. n)then
!!$              lem(m,n) = 1.0d0
!!$              rem(m,n) = 1.0d0
!!$           end if
!!$        end do
!!$     end do

              do l=1,5
                 do n=1,nwave
                    wwc(n,l) = lem(n,1)*ww(1,l)
                    do m=2,nwave
                       wwc(n,l) = wwc(n,l)+lem(n,m)*ww(m,l)
                    enddo
                 enddo
              end do
              
              ! mp5
              do n=1,nwave
                 wwor = B1*(ccy(1,2,j)*wwc(n,1)+ccy(2,2,j)*wwc(n,2) &
                      + ccy(3,2,j)*wwc(n,3) + ccy(4,2,j)*wwc(n,4) &
                      + ccy(5,2,j)*wwc(n,5))
                 djm1 = wwc(n,1)-2.0d0*wwc(n,2)+wwc(n,3)
                 dj = wwc(n,2)-2.0d0*wwc(n,3)+wwc(n,4)
                 djp1 = wwc(n,3)-2.0d0*wwc(n,4)+wwc(n,5)
                 
                 dm4jph = minmod4(4.0d0*dj-djp1,4.0d0*djp1-dj,dj,djp1)
                 dm4jmh = minmod4(4.0d0*dj-djm1,4.0d0*djm1-dj,dj,djm1)
                 
                 qqul = wwc(n,3)+Alpha*(wwc(n,3)-wwc(n,2))
                 qqlr = wwc(n,4)+Alpha*(wwc(n,4)-wwc(n,5))
                 
                 qqav = 0.5d0*(wwc(n,3)+wwc(n,4))
                 qqmd = qqav - 0.5d0*dm4jph
                 qqlc = wwc(n,3) + 0.5d0*(wwc(n,3)-wwc(n,2)) + B2*dm4jmh
                 
                 qqmin = max(min(wwc(n,3),wwc(n,4),qqmd),min(wwc(n,3),qqul,qqlc))
                 qqmax = min(max(wwc(n,3),wwc(n,4),qqmd),max(wwc(n,3),qqul,qqlc))

                 wwc_w(n) = wwor + minmod((qqmin-wwor),(qqmax-wwor))

              end do
              
              ! characteristic to primitive
              do n=1,nwave
                 qqr(n) = wwc_w(1)*rem(n,1)
                 do m=2,nwave
                    qqr(n) = qqr(n)+wwc_w(m)*rem(n,m)
                 enddo
              enddo
              ! right state
              ! mp5
              do n=1,nwave
                 wwor = B1*(ccy(5,1,j-1)*wwc(n,5)+ccy(4,1,j-1)*wwc(n,4) &
                      + ccy(3,1,j-1)*wwc(n,3) + ccy(2,1,j-1)*wwc(n,2) &
                      + ccy(1,1,j-1)*wwc(n,1))
                 djm1 = wwc(n,1)-2.0d0*wwc(n,2)+wwc(n,3)
                 dj = wwc(n,2)-2.0d0*wwc(n,3)+wwc(n,4)
                 djp1 = wwc(n,3)-2.0d0*wwc(n,4)+wwc(n,5)
                 
                 dm4jph = minmod4(4.0d0*dj-djp1,4.0d0*djp1-dj,dj,djp1)
                 dm4jmh = minmod4(4.0d0*dj-djm1,4.0d0*djm1-dj,dj,djm1)
                 
                 qqul = wwc(n,2)+Alpha*(wwc(n,2)-wwc(n,1))
                 qqlr = wwc(n,3)+Alpha*(wwc(n,3)-wwc(n,4))
                 
                 qqav = 0.5d0*(wwc(n,3)+wwc(n,2))
                 qqmd = qqav - 0.5d0*dm4jmh
                 qqlc = wwc(n,3) + 0.5d0*(wwc(n,3)-wwc(n,4)) + B2*dm4jph
                 
                 qqmin = max(min(wwc(n,3),wwc(n,2),qqmd),min(wwc(n,3),qqlr,qqlc))
                 qqmax = min(max(wwc(n,3),wwc(n,2),qqmd),max(wwc(n,3),qqlr,qqlc))
                 
                 wwc_w(n) = wwor + minmod((qqmin-wwor),(qqmax-wwor))
              end do
              
              ! characteristic to primitive
              do n=1,nwave
                 qql(n) = wwc_w(1)*rem(n,1)
                 do m=2,nwave
                    qql(n) = qql(n)+wwc_w(m)*rem(n,m)
                 enddo
              enddo

              qql(1) = max(min(ro(i,j,k),ro(i,j-1,k)),qql(1))
              qql(1) = min(max(ro(i,j,k),ro(i,j-1,k)),qql(1))
              qqr(1) = max(min(ro(i,j,k),ro(i,j+1,k)),qqr(1))
              qqr(1) = min(max(ro(i,j,k),ro(i,j+1,k)),qqr(1))
              
              qql(2) = max(min(vx(i,j,k),vx(i,j-1,k)),qql(2))
              qql(2) = min(max(vx(i,j,k),vx(i,j-1,k)),qql(2))
              qqr(2) = max(min(vx(i,j,k),vx(i,j+1,k)),qqr(2))
              qqr(2) = min(max(vx(i,j,k),vx(i,j+1,k)),qqr(2))
              
              qql(3) = max(min(vy(i,j,k),vy(i,j-1,k)),qql(3))
              qql(3) = min(max(vy(i,j,k),vy(i,j-1,k)),qql(3))
              qqr(3) = max(min(vy(i,j,k),vy(i,j+1,k)),qqr(3))
              qqr(3) = min(max(vy(i,j,k),vy(i,j+1,k)),qqr(3))
              
              qql(4) = max(min(vz(i,j,k),vz(i,j-1,k)),qql(4))
              qql(4) = min(max(vz(i,j,k),vz(i,j-1,k)),qql(4))
              qqr(4) = max(min(vz(i,j,k),vz(i,j+1,k)),qqr(4))
              qqr(4) = min(max(vz(i,j,k),vz(i,j+1,k)),qqr(4))
              
              qql(5) = max(min(pr(i,j,k),pr(i,j-1,k)),qql(5))
              qql(5) = min(max(pr(i,j,k),pr(i,j-1,k)),qql(5))
              qqr(5) = max(min(pr(i,j,k),pr(i,j+1,k)),qqr(5))
              qqr(5) = min(max(pr(i,j,k),pr(i,j+1,k)),qqr(5))
              
              qql(6) = max(min(bx(i,j,k),bx(i,j-1,k)),qql(6))
              qql(6) = min(max(bx(i,j,k),bx(i,j-1,k)),qql(6))
              qqr(6) = max(min(bx(i,j,k),bx(i,j+1,k)),qqr(6))
              qqr(6) = min(max(bx(i,j,k),bx(i,j+1,k)),qqr(6))
              
              qql(7) = max(min(by(i,j,k),by(i,j-1,k)),qql(7))
              qql(7) = min(max(by(i,j,k),by(i,j-1,k)),qql(7))
              qqr(7) = max(min(by(i,j,k),by(i,j+1,k)),qqr(7))
              qqr(7) = min(max(by(i,j,k),by(i,j+1,k)),qqr(7))
              
              qql(8) = max(min(bz(i,j,k),bz(i,j-1,k)),qql(8))
              qql(8) = min(max(bz(i,j,k),bz(i,j-1,k)),qql(8))
              qqr(8) = max(min(bz(i,j,k),bz(i,j+1,k)),qqr(8))
              qqr(8) = min(max(bz(i,j,k),bz(i,j+1,k)),qqr(8))
              
              qql(9) = max(min(phi(i,j,k),phi(i,j-1,k)),qql(9))
              qql(9) = min(max(phi(i,j,k),phi(i,j-1,k)),qql(9))
              qqr(9) = max(min(phi(i,j,k),phi(i,j+1,k)),qqr(9))
              qqr(9) = min(max(phi(i,j,k),phi(i,j+1,k)),qqr(9))
              
              row(i,j-1,k,2) = qql(1)
              row(i,j,k,1) = qqr(1)
              
              vxw(i,j-1,k,2) = qql(2)
              vxw(i,j,k,1) = qqr(2)
              vyw(i,j-1,k,2) = qql(3)
              vyw(i,j,k,1) = qqr(3)
              vzw(i,j-1,k,2) = qql(4)
              vzw(i,j,k,1) = qqr(4)
              
              prw(i,j-1,k,2) = qql(5)
              prw(i,j,k,1) = qqr(5)
              
              bxw(i,j-1,k,2) = qql(6)
              bxw(i,j,k,1) = qqr(6)
              byw(i,j-1,k,2) = qql(7)
              byw(i,j,k,1) = qqr(7)
              bzw(i,j-1,k,2) = qql(8)
              bzw(i,j,k,1) = qqr(8)
              
              phiw(i,j-1,k,2) = qql(9)
              phiw(i,j,k,1) = qqr(9)
           end do
        end do
     end do
  else
     do k=3,kx-2
        do j=3,jx-2
           do i=3,ix-2
              do n=1,5
                 ww(1,n) = ro(i,j,k-3+n)
                 ww(2,n) = vx(i,j,k-3+n)
                 ww(3,n) = vy(i,j,k-3+n)
                 ww(4,n) = vz(i,j,k-3+n)
                 ww(5,n) = pr(i,j,k-3+n)
                 ww(6,n) = bx(i,j,k-3+n)
                 ww(7,n) = by(i,j,k-3+n)
                 ww(8,n) = bz(i,j,k-3+n)
                 ww(9,n) = phi(i,j,k-3+n)
              end do
              ! left state
              
              ! primitive ro characteristic
              
              ro1 = ro(i,j,k)
              pr1 = pr(i,j,k)
              vx1 = vx(i,j,k)
              vy1 = vy(i,j,k)
              vz1 = vz(i,j,k)
              bx1 = bx(i,j,k)
              by1 = by(i,j,k)
              bz1 = bz(i,j,k)
              phi1 = phi(i,j,k)
              
              call esystem_glmmhd(lem,rem,ro1,pr1,vx1,vy1,vz1,bx1,by1,bz1,phi1,ch,gm)
              
!!$     do m=1,nwave
!!$        do n=1,nwave
!!$           lem(m,n) = 0.0d0
!!$           rem(m,n) = 0.0d0
!!$           if(m .eq. n)then
!!$              lem(m,n) = 1.0d0
!!$              rem(m,n) = 1.0d0
!!$           end if
!!$        end do
!!$     end do

              do l=1,5
                 do n=1,nwave
                    wwc(n,l) = lem(n,1)*ww(1,l)
                    do m=2,nwave
                       wwc(n,l) = wwc(n,l)+lem(n,m)*ww(m,l)
                    enddo
                 enddo
              end do
              
              ! mp5
              do n=1,nwave
                 wwor = B1*(ccz(1,2,k)*wwc(n,1)+ccz(2,2,k)*wwc(n,2) &
                      + ccz(3,2,k)*wwc(n,3) + ccz(4,2,k)*wwc(n,4) &
                      + ccz(5,2,k)*wwc(n,5))
                 djm1 = wwc(n,1)-2.0d0*wwc(n,2)+wwc(n,3)
                 dj = wwc(n,2)-2.0d0*wwc(n,3)+wwc(n,4)
                 djp1 = wwc(n,3)-2.0d0*wwc(n,4)+wwc(n,5)
                 
                 dm4jph = minmod4(4.0d0*dj-djp1,4.0d0*djp1-dj,dj,djp1)
                 dm4jmh = minmod4(4.0d0*dj-djm1,4.0d0*djm1-dj,dj,djm1)
                 
                 qqul = wwc(n,3)+Alpha*(wwc(n,3)-wwc(n,2))
                 qqlr = wwc(n,4)+Alpha*(wwc(n,4)-wwc(n,5))
                 
                 qqav = 0.5d0*(wwc(n,3)+wwc(n,4))
                 qqmd = qqav - 0.5d0*dm4jph
                 qqlc = wwc(n,3) + 0.5d0*(wwc(n,3)-wwc(n,2)) + B2*dm4jmh
                 
                 qqmin = max(min(wwc(n,3),wwc(n,4),qqmd),min(wwc(n,3),qqul,qqlc))
                 qqmax = min(max(wwc(n,3),wwc(n,4),qqmd),max(wwc(n,3),qqul,qqlc))

                 wwc_w(n) = wwor + minmod((qqmin-wwor),(qqmax-wwor))
              end do
              
              ! characteristic to primitive
              do n=1,nwave
                 qqr(n) = wwc_w(1)*rem(n,1)
                 do m=2,nwave
                    qqr(n) = qqr(n)+wwc_w(m)*rem(n,m)
                 enddo
              enddo
              ! right state
              ! mp5
              do n=1,nwave
                 wwor = B1*(ccz(5,1,k-1)*wwc(n,5)+ccz(4,1,k-1)*wwc(n,4) &
                      + ccz(3,1,k-1)*wwc(n,3) + ccz(2,1,k-1)*wwc(n,2) &
                      + ccz(1,1,k-1)*wwc(n,1))
                 djm1 = wwc(n,1)-2.0d0*wwc(n,2)+wwc(n,3)
                 dj = wwc(n,2)-2.0d0*wwc(n,3)+wwc(n,4)
                 djp1 = wwc(n,3)-2.0d0*wwc(n,4)+wwc(n,5)
                 
                 dm4jph = minmod4(4.0d0*dj-djp1,4.0d0*djp1-dj,dj,djp1)
                 dm4jmh = minmod4(4.0d0*dj-djm1,4.0d0*djm1-dj,dj,djm1)
                 
                 qqul = wwc(n,2)+Alpha*(wwc(n,2)-wwc(n,1))
                 qqlr = wwc(n,3)+Alpha*(wwc(n,3)-wwc(n,4))
                 
                 qqav = 0.5d0*(wwc(n,3)+wwc(n,2))
                 qqmd = qqav - 0.5d0*dm4jmh
                 qqlc = wwc(n,3) + 0.5d0*(wwc(n,3)-wwc(n,4)) + B2*dm4jph
                 
                 qqmin = max(min(wwc(n,3),wwc(n,2),qqmd),min(wwc(n,3),qqlr,qqlc))
                 qqmax = min(max(wwc(n,3),wwc(n,2),qqmd),max(wwc(n,3),qqlr,qqlc))
                 
                 wwc_w(n) = wwor + minmod((qqmin-wwor),(qqmax-wwor))
              end do
              
              ! characteristic to primitive
              do n=1,nwave
                 qql(n) = wwc_w(1)*rem(n,1)
                 do m=2,nwave
                    qql(n) = qql(n)+wwc_w(m)*rem(n,m)
                 enddo
              enddo

              qql(1) = max(min(ro(i,j,k),ro(i,j,k-1)),qql(1))
              qql(1) = min(max(ro(i,j,k),ro(i,j,k-1)),qql(1))
              qqr(1) = max(min(ro(i,j,k),ro(i,j,k+1)),qqr(1))
              qqr(1) = min(max(ro(i,j,k),ro(i,j,k+1)),qqr(1))
              
              qql(2) = max(min(vx(i,j,k),vx(i,j,k-1)),qql(2))
              qql(2) = min(max(vx(i,j,k),vx(i,j,k-1)),qql(2))
              qqr(2) = max(min(vx(i,j,k),vx(i,j,k+1)),qqr(2))
              qqr(2) = min(max(vx(i,j,k),vx(i,j,k+1)),qqr(2))
              
              qql(3) = max(min(vy(i,j,k),vy(i,j,k-1)),qql(3))
              qql(3) = min(max(vy(i,j,k),vy(i,j,k-1)),qql(3))
              qqr(3) = max(min(vy(i,j,k),vy(i,j,k+1)),qqr(3))
              qqr(3) = min(max(vy(i,j,k),vy(i,j,k+1)),qqr(3))
              
              qql(4) = max(min(vz(i,j,k),vz(i,j,k-1)),qql(4))
              qql(4) = min(max(vz(i,j,k),vz(i,j,k-1)),qql(4))
              qqr(4) = max(min(vz(i,j,k),vz(i,j,k+1)),qqr(4))
              qqr(4) = min(max(vz(i,j,k),vz(i,j,k+1)),qqr(4))
              
              qql(5) = max(min(pr(i,j,k),pr(i,j,k-1)),qql(5))
              qql(5) = min(max(pr(i,j,k),pr(i,j,k-1)),qql(5))
              qqr(5) = max(min(pr(i,j,k),pr(i,j,k+1)),qqr(5))
              qqr(5) = min(max(pr(i,j,k),pr(i,j,k+1)),qqr(5))
              
              qql(6) = max(min(bx(i,j,k),bx(i,j,k-1)),qql(6))
              qql(6) = min(max(bx(i,j,k),bx(i,j,k-1)),qql(6))
              qqr(6) = max(min(bx(i,j,k),bx(i,j,k+1)),qqr(6))
              qqr(6) = min(max(bx(i,j,k),bx(i,j,k+1)),qqr(6))
              
              qql(7) = max(min(by(i,j,k),by(i,j,k-1)),qql(7))
              qql(7) = min(max(by(i,j,k),by(i,j,k-1)),qql(7))
              qqr(7) = max(min(by(i,j,k),by(i,j,k+1)),qqr(7))
              qqr(7) = min(max(by(i,j,k),by(i,j,k+1)),qqr(7))
              
              qql(8) = max(min(bz(i,j,k),bz(i,j,k-1)),qql(8))
              qql(8) = min(max(bz(i,j,k),bz(i,j,k-1)),qql(8))
              qqr(8) = max(min(bz(i,j,k),bz(i,j,k+1)),qqr(8))
              qqr(8) = min(max(bz(i,j,k),bz(i,j,k+1)),qqr(8))
              
              qql(9) = max(min(phi(i,j,k),phi(i,j,k-1)),qql(9))
              qql(9) = min(max(phi(i,j,k),phi(i,j,k-1)),qql(9))
              qqr(9) = max(min(phi(i,j,k),phi(i,j,k+1)),qqr(9))
              qqr(9) = min(max(phi(i,j,k),phi(i,j,k+1)),qqr(9))
              
              row(i,j,k-1,2) = qql(1)
              row(i,j,k,1) = qqr(1)
              
              vxw(i,j,k-1,2) = qql(2)
              vxw(i,j,k,1) = qqr(2)
              vyw(i,j,k-1,2) = qql(3)
              vyw(i,j,k,1) = qqr(3)
              vzw(i,j,k-1,2) = qql(4)
              vzw(i,j,k,1) = qqr(4)
              
              prw(i,j,k-1,2) = qql(5)
              prw(i,j,k,1) = qqr(5)
              
              bxw(i,j,k-1,2) = qql(6)
              bxw(i,j,k,1) = qqr(6)
              byw(i,j,k-1,2) = qql(7)
              byw(i,j,k,1) = qqr(7)
              bzw(i,j,k-1,2) = qql(8)
              bzw(i,j,k,1) = qqr(8)
              
              phiw(i,j,k-1,2) = qql(9)
              phiw(i,j,k,1) = qqr(9)
           end do
        end do
     end do
  end if
  return
end subroutine MP5_reconstruction_charGlmMhd2
