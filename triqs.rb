class Triqs < Formula
  include Language::Python::Virtualenv

  desc "Toolbox for Research on Interacting Quantum Systems"
  homepage "https://triqs.ipht.cnrs.fr/"
  url "https://github.com/Wentzell/triqs/archive/1.4.1.tar.gz"
  sha256 "d9eae1d87bf04a2dcfdb302ea86352b10277f1e6afccfdaee205aa744d49768c"
  head "https://github.com/Wentzell/triqs.git"

  # doi "10.1016/j.cpc.2015.04.023"
  # tag "quantumphysics"

  option "with-test", "Build and run shipped tests"

  depends_on "cmake" => :build
  depends_on :mpi => :cxx
  depends_on "boost"
  depends_on "hdf5"
  depends_on "fftw"
  depends_on "gmp"
  depends_on "pkg-config" => :run
  depends_on :python
  depends_on "scipy"
  depends_on "numpy"

  resource "mako" do
    url "https://pypi.python.org/packages/eb/f3/67579bb486517c0d49547f9697e36582cd19dafb5df9e687ed8e22de57fa/Mako-1.0.7.tar.gz"
    sha256 "4e02fde57bd4abb5ec400181e4c314f56ac3e49ba4fb8b0d50bba18cb27d25ae"
  end

  resource "jupyter" do
    url "https://pypi.python.org/packages/fc/21/a372b73e3a498b41b92ed915ada7de2ad5e16631546329c03e484c3bf4e9/jupyter-1.0.0.zip"
    sha256 "3e1f86076bbb7c8c207829390305a2b1fe836d471ed54be66a3b8c41e7f46cc7"
  end

  resource "h5py" do
    url "https://pypi.python.org/packages/11/6b/32cee6f59e7a03ab7c60bb250caff63e2d20c33ebca47cf8c28f6a2d085c/h5py-2.7.0.tar.gz"
    sha256 "79254312df2e6154c4928f5e3b22f7a2847b6e5ffb05ddc33e37b16e76d36310"
  end

  resource "mpi4py" do
    url "https://pypi.python.org/packages/ee/b8/f443e1de0b6495479fc73c5863b7b5272a4ece5122e3589db6cd3bb57eeb/mpi4py-2.0.0.tar.gz"
    sha256 "6543a05851a7aa1e6d165e673d422ba24e45c41e4221f0993fe1e5924a00cb81"
  end

  def install

    ENV.cxx11
    ENV.prepend_path "PYTHONPATH", Formula["numpy"].opt_lib/"python2.7/site-packages"
    ENV.prepend_path "PYTHONPATH", Formula["scipy"].opt_lib/"python2.7/site-packages"

    venv = virtualenv_create(libexec/"venv")
    venv.pip_install resources
    ENV.prepend_path "PYTHONPATH", libexec/"venv/lib/python2.7/site-packages"

    args = %W[
      ..
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_INSTALL_PREFIX=#{prefix}
    ]
    args << ("-DBuild_Tests=" + (build.with?("test") ? "ON " : "OFF "))

    mkdir "build" do
      system "cmake", *args
      ENV.deparallelize { system "make" }
      system "make", "test" if build.with? "test"
      system "make", "install"
    end

    chmod 0555, bin/"clang_parser.py"
    chmod 0555, bin/"cpp2doc_tools.py"

  end

  test do
    system "python -c 'import pytriqs'"
  end
end
