class Triqs < Formula
  desc "Applications and Libraries for Physics Simulations"
  homepage "http://triqs.ipht.cnrs.fr/"

  head "https://github.com/TRIQS/triqs.git"

  stable do
    url "https://github.com/TRIQS/triqs/archive/1.4.tar.gz"
    sha256 "98378d5fb934c02f710d96eb5a3ffa28cbee20bab73b574487f5db18c5457cc4"
  end  

  devel do
    url "https://github.com/TRIQS/triqs.git", :branch => "unstable"
  end  

  option "with-test", "Build and run shipped tests"

  depends_on "cmake" => :build
  depends_on :mpi => :cxx

  depends_on "boost"
  depends_on "open-mpi"
  depends_on "hdf5"
  depends_on "cmake" => :build
  depends_on "fftw"
  depends_on "gmp"
  depends_on "pkg-config" => :run
  depends_on "python"
  depends_on "numpy" => :python
  depends_on "scipy" => :python

  def install
    system "pip", "install", "mako"
    system "pip", "install", "--no-binary=h5py", "h5py"
    system "pip", "install", "--no-binary=mpi4py", "mpi4py"

    ENV.cxx11
    args = ".." 
    args << "-DCMAKE_BUILD_TYPE=Release"
    args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    args << ("-DBuild_Tests=" + ((build.with? "test") ? "ON" : "OFF"))

    mkdir "build" do
      args << ".."
      system "cmake", *args
      system "make -j 1"
      system "make", "test" if build.with? "test"
      system "make", "install"
    end
  end

  def post_install
    chmod 0555, bin/"clang_parser.py"
    chmod 0555, bin/"cpp2doc_tools.py"
  end

  test do
    system "python -c 'import pytriqs'"
  end
end
