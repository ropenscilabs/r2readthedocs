.. documentation master file, created by sphinx-quickstart 
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

reStructuredText
================================

.. raw:: html

    <style> .red {color:red} </style>

.. role:: red

This main document is in `'reStructuredText' ("rst") format
<https://www.sphinx-doc.org/en/master/usage/restructuredtext/index.html>`_,
which differs in many ways from standard markdown commonly used in R packages.
``rst`` is richer and more powerful than markdown. The remainder of this main
package demonstrates some of the features, with links to additional ``rst``
documentation to help you get started. The definitive argument for the benefits
of ``rst`` over markdown is the `official language format documentation
<https://www.python.org/dev/peps/pep-0287/>`_, which starts with a very clear
explanation of the benefits.

Examples
--------

All of the following are defined within the `docs/index.rst` file. Here is some
:red:`coloured` text which demonstrates how raw html commands can be
incorporated. The following are examples of ``rst`` "admonitions":

.. note::

    Here is a note

    .. warning::

        With a warning inside the note

.. seealso::

    The full list of `'restructuredtext' directives <https://www.sphinx-doc.org/en/master/usage/restructuredtext/directives.html>`_ or a similar list of `admonitions <https://restructuredtext.documatt.com/admonitions.html>`_.

.. centered:: This is a line of :red:`centered text`

.. hlist::
   :columns: 3

   * and here is
   * A list of
   * short items
   * that should be
   * displayed
   * in 3 columns

.. toctree::
   :maxdepth: 1
   :caption: Introduction:

   demo
