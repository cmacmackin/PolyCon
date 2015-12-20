module stack_mod
  use abstract_container_mod
  implicit none
  private  

  type :: node
    private
    class(container_type), allocatable ::  contents
    type(node), pointer :: next => null()
  !contains
  !  final :: node_destructor
  end type node

  type :: stack
    private
    class(container_type), allocatable :: cont
    type(node), pointer :: head => null()
  contains
    private
    procedure, public :: push 
    procedure, public :: pop
    procedure, public :: peek
    final :: destructor
  end type stack

  interface stack
    module procedure constructor
  end interface stack

  public :: stack

contains

  function constructor(container) result(retval)
    class(container_type), intent(in) :: container
    type(stack) :: retval
    allocate(retval%cont, mold=container)
  end function

  subroutine push(this, val)
    class(stack), intent(inout) :: this
    class(*), intent(in) :: val
    type(node), pointer :: newnode
    allocate(newnode)
    allocate(newnode%contents, mold=this%cont)
    call newnode%contents%set(val)
    newnode%next => this%head
    this%head => newnode
  end subroutine push

  function pop(this) result(val)
    class(stack), intent(inout) :: this
    class(container_type), allocatable :: val
    type(node), pointer :: tmp
    if (.not. associated(this%head)) then
      write(*,*) 'Error: stack is empty.'
      stop 1
    end if
    allocate(val, source=this%head%contents)
    tmp => this%head
    if (associated(tmp%next)) then
      this%head => tmp%next
    else
      nullify(this%head)
    endif
    deallocate(tmp)
  end function pop

  function peek(this) result(val)
    class(stack), intent(in) :: this
    class(container_type), allocatable :: val
    if (.not. associated(this%head)) then
      write(*,*) 'Error: stack is empty.'
      stop 1
    end if
    allocate(val, source=this%head%contents)
  end function peek

  subroutine destructor(this)
    type(stack), intent(inout) :: this
    type(node), pointer :: n
    type(node), pointer :: tmp
    n => this%head
    do while(associated(n))
      tmp => n
      n => tmp%next
      deallocate(tmp)
    end do
  end subroutine destructor

  !subroutine node_destructor(this)
  !  type(node), intent(inout) :: this
  !  if (associated(this%next)) deallocate(this%next)
  !end subroutine node_destructor

end module stack_mod


program stack_test
  use container_mod, only: int_container
  use stack_mod
  implicit none

  type(int_container) :: cont
  integer :: in1 = 1, in2 = 2, in3 = 3, out1 = 0, out2 = 0, out3 = 0, errs = 0
  type(stack) :: st

  write(*,*) 'Initializing stack.'
  st = stack(cont)
  write(*,*) 'Placing first value in stack.'
  call st%push(in1)
  write(*,*) 'Placing second value in stack.'
  call st%push(in2)
  write(*,*) 'Placing third value in stack.'
  call st%push(in3)
  
  write(*,*) 'Retreiving third value from stack.'
  out3 = st%pop()
  write(*,*) 'Retreiving second value from stack.'
  out2 = st%pop()
  write(*,*) 'Retreiving first value from stack.'
  out1 = st%pop()

  if (in1 /= out1) errs = errs + 1
  if (in2 /= out2) errs = errs + 1
  if (in3 /= out3) errs = errs + 1
  if (errs > 0) then
    write(*,*) 'Stack test FAILED.'
  else
    write(*,*) 'Stack test PASSED.'
  end if

end program stack_test
