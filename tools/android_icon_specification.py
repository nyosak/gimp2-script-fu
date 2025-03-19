#!/usr/bin/env python3

r"""
generates a case list for android icon creator
copyright 2025, hanagai

android_icon_specification.py
version: March 19, 2025; 17:40 JST

bash script to create subfolders
case list for GIMP Script-Fu

See Document class for details.
"""

import argparse
import re
import sys

r"""
document
"""

class Document:
  r"""
  documents and args parameter for this script
  """

  prog = "android_icon_specification.py"
  description = """
Generates a case list for android icon creator:
case list for GIMP Script-Fu.
bash script to create subfolders.
""".strip()
  epilog = "use with GIMP script-fu Android Icon Generator"

  arguments = (
    ("project", "project name", "MyProject"),
    ("version", "version name", "MyVersion"),
    ("--build", "build type", "main,debug,release"),
    ("--shape", "icon shape", "square,round"),
    ("--size", "icon size", "48,72,96,144,192"),
  )
  r"""
  key, description, example
  these are used by argparse at main().
  """

  _linefeed = "\n"
  _tab = "\t"

  usage = f"""
{prog}

{description}

usage:
{_tab}{prog} [{'] ['.join('%s' % k for k,d,e in arguments)}]
{_tab}{prog} {' '.join(
  ('[%s=%s]' % (k,e)) if k.startswith('-') else ('%s' % e) for k,d,e in arguments
)}

arguments:
{
  _linefeed.join('🍊%s:🍊%s (%s)' % item for item in arguments).replace('🍊', _tab)
}

{epilog}
"""

  overview = r"""

%%{init:
	{
		"theme": "forest",
		"logLevel": 2,
		"flowchart": { "curve": "linear" }
	}
}%%

flowchart TB

	Document -- define args --> main

	HierarchyDefault -- initialize --> Hierarchy
	Instruction -- update --> Hierarchy
	Iterator -- iterate --> Instruction

	Collector -- subclass --> TreeCollector
	Collector -- subclass --> LeafCollector

	Hierarchy -- directory --> TreeMaker
	Iterator -- "dangeon map" --> TreeMaker
	TreeMaker -- deeper --> FloorMixer -- deeper --> RoomMixer

	FloorMixer -- gather ----> LeafCollector
	FloorMixer -- gather ----> TreeCollector
	RoomMixer -- gather ----> LeafCollector
	RoomMixer -- gather ----> TreeCollector

	TreeCollector -- tree --> TreeMaker
	LeafCollector -- leaf --> FloorMixer
	LeafCollector -- leaf --> RoomMixer

	main("main()") -- run --> Executor
	Executor -- run --> TreeMaker

	TreeMaker -- create --> the_tree
	the_tree -- transform --> bash
	the_tree -- transform --> scheme

	Executor --- the_tree[(the tree)]
	Executor --- bash[(bash mkdir)]
	Executor --- scheme[(scheme list)]

	command([command line]) ----> main
	bash -- stdout --> output([output result])
	scheme -- stdout --> output

	Test

subgraph documents
	Document
end

subgraph hierarchies
	HierarchyDefault
	Hierarchy
	Iterator
	Instruction
end

subgraph collectors
	Collector
	TreeCollector
	LeafCollector
end

subgraph tree
	RoomMixer
	FloorMixer
	TreeMaker
end

subgraph runner
	Executor
	main
	the_tree
	bash
	scheme
end

subgraph tests
	Test
end

linkStyle default color:#936, stroke:#f69, stroke-width:2px;
classDef default fill:#fcc, stroke:#345, stroke-width:3px, font-size:14pt;

"""

  origin = r"""
# directory

- user home
- studio home
- project
- version
- src
- build
- res
- mipmap
- icon name

# fixed

- user home
- studio home
- src
- res

# variable

- project
- version
- build
- mipmap
- icon name

# fixed values

- user home : /home/kuro
- studio home : AndroidStudioProjects
- src : app/src
- res : res

# variable values

- project : angulatus ,,,
- version : b2 ,,,
- build : main, debug, release
- mipmap : 'see mipmaps
- icon name : ic_launcher.webp, ic_launcher_round.webp

# mipmaps

- mipmap-mdpi : 48
- mipmap-hdpi : 72
- mipmap-xhdpi : 96
- mipmap-xxhdpi : 144
- mipmap-xxxhdpi : 192

---
© 2025 hanagai
🌸🐚
"""

r"""
hierarchy, definition of structure
"""

class HierarchyDefault:
  r"""
  default values on initialization
  """

  directories = (
    "user_home",
    "studio_home",
    "project",
    "version",
    "src",
    "build",
    "res",
    "mipmap",
    "icon_name"
  )
  r"""
  segments of hierarchy of directory

  the order is important.
  user_home locates directly below the root directory.
  icon_name is the file name.
  others are subdirectories locate with this order.

  it is safe to customize this list.
  remember to give default values as followings.
  """

  user_home = "/home/kuro"
  r"""
  user home directory, directly below the root
  """

  studio_home = "AndroidStudioProjects"
  r"""
  project home directory of Android Studio, under the _user_home
  """

  project = "MyProject"
  r"""
  project directory name, under the _studio_home
  expects to be overwritten by command line argument.
  """

  version = "MyVersion"
  r"""
  project version directory name, under the _project
  expects to be overwritten by command line argument.

  project home at Android Studio will be _studio_home/_project/_version.
  set blank string for _version unless required.
  """

  src = "app/src"
  r"""
  location of java sources and resouces, under the project home
  """

  build = "main"
  r"""
  source category for different type of build, under the source location
  typically one of (main, debug, release).
  to be iterated.
  """

  res = "res"
  r"""
  resource directory, under the _build
  """

  mipmap = "mipmap-mdpi"
  r"""
  mipmap-* directory for variety sized icons, under the _res

  one of (mipmap-mdpi, mipmap-hdpi, mipmap-xhdpi,
          mipmap-xxhdpi, mipmap-xxxhdpi)
  to be iterated.
  """

  icon_name = "ic_launcher.webp"
  r"""
  file name of icon, under _mipmap

  one of (ic_launcher_round.webp, ic_launcher.webp)
  to be iterated.
  """


class Hierarchy:
  r"""
  hierarchy of directory

  A instance of Hierarchy is paired with an icon.
  Insted of creating as many as instances to icons required,
  sets each instruction instance to fit each icon.

  It does not explicitly define each property.
  All properties are set in common `_bag` to be flexible.

  `instruction` is a special property to accept iteratable properties,
  so it is not in the  `_bag`.
  """

  def __init__(self, **kwargs):
    self.on_initialize_bag()
    intersection = {k: kwargs[k] for k in kwargs if k in self._bag}
    for k in intersection.keys():
      self._bag[k] = intersection[k]
    r"""
    accept only keys defined in HierarcyDefault
    """

  def __str__(self):
    return (
      f"Hierarchy(" +
      ", ".join(f"{k}={v}" for k,v in self._bag.items()) +
      f")"
    )

  def get(self):
    return self._bag.copy()

  def on_initialize_bag(self):
    the_dict = HierarchyDefault.__dict__
    sub_keys = [k for k in the_dict.keys() if not k.startswith("_") and k != "instruction"]
    self._bag = {k: the_dict[k] for k in sub_keys}
    r"""
    initialize property _bag with HierarcyDefault
    instruction should not be set at initialization
    """

  def on_set_instruction(self, value):
    self._bag.update(value.get())
    r"""
    update multiple properties by instruction
    the keys are not checked, so this process can add keys.
    """

  def update(self, *conditions):
    instruction = Instruction()
    for condition in conditions:
      instruction.update(**condition)
    self.instruction = instruction
    return self
    r"""
    update through instrucion by condition list
    """

  def __getattr__(self, name):
    if (name in self._bag):
      return self._bag[name]
    else:
      super(self.__class__, self).__getattribute__(name)

  def __setattr__(self, name, value):
    if (name == "instruction"):
      self.on_set_instruction(value)
    elif (name != "_bag") and (name in self._bag):
      self._bag[name] = value
    else:
      super(self.__class__, self).__setattr__(name, value)


class Iterator:
  r"""
  list to iterate

  This class have iterating properties of Hierarcy.
  """

  key_list = ("build", "size", "shape")

  _build = (
    "main",
    "debug",
    "release"
  )

  _size = (
    48,
    72,
    96,
    144,
    192
  )
  r"""
  icon size affects to _mipmap
  """

  _shape = (
    "square",
    "round"
  )
  r"""
  icon shape affects to _icon_name
  """

  @classmethod
  def mipmap_by_size(cls, size):
    match size:
      case 48:
        return "mipmap-mdpi"
      case 72:
        return "mipmap-hdpi"
      case 96:
        return "mipmap-xhdpi"
      case 144:
        return "mipmap-xxhdpi"
      case 192:
        return "mipmap-xxxhdpi"
      case _:
        return f"UNKNOWN_{size}"

  @classmethod
  def icon_name_by_shape(cls, shape):
    match shape:
      case "round":
        return "ic_launcher_round.webp"
      case "square":
        return "ic_launcher.webp"
      case _:
        return f"UNKNOWN_{shape}.webp"

  @classmethod
  def convert(cls, iterator_key, iterator_value):
    match iterator_key:
      case "build":
        return ("build", iterator_value)
      case "size":
        return ("mipmap", cls.mipmap_by_size(iterator_value))
      case "shape":
        return ("icon_name", cls.icon_name_by_shape(iterator_value))
      case _:
        return ()
    r"""
    convert Iterator style key-value into Hierarcy style.
    For Instruction
    """

  @classmethod
  def to_iterable(cls, value):
    try:
      is_iterable = iter(value)
    except TypeError:
      return [value]

    r"""
    not as smart as below, but better
    is_iterable = isinstance(value, list) or isinstance(value, tuple)

    do not use tuple to return value here.
    single value tuple will be casted to be a basic value.
    string is to be iterable, so fix it as followings.

    every property here must be iterable.
    instead of rejecting a basic single value,
    create an iterable including the value.

    """
    return [value] if isinstance(value, str) else value

  @classmethod
  def clean_kwargs(cls, kwargs):
    return {k: kwargs[k] for k in cls.key_list if k in kwargs.keys()}
    r"""
    when initializing by a kwargs through command line,
    use this to clean keys to avoid error by unrecognized arguments.
    """

  def __init__(self, build=_build, size=_size, shape=_shape):
    if None != build:
      self._build = self.to_iterable(build)
    if None != size:
      self._size = self.to_iterable(size)
    if None != shape:
      self._shape = self.to_iterable(shape)
    r"""
    allow `None` when using kwargs, {"shape":None} is ignored.
    """

  def __str__(self):
    return(
      f"Iterator("
      f"build={self.build}, "
      f"size={self.size}, "
      f"shape={self.shape}"
      f")"
    )

  def list_for(self, name):
    r"""
    'build' -> self._build, and so on
    """
    return self.__getattribute__(f"_{name}")

  def dict_for(self, name):
    r"""
    convert each item to a dict with key=name
    """
    return list({name: item} for item in self.list_for(name))

  @property
  def build(self):
    return self._build

  @build.setter
  def build(self, value):
    self._build = value

  @property
  def size(self):
    return self._size

  @size.setter
  def size(self, value):
    self._size = value

  @property
  def shape(self):
    return self._shape

  @shape.setter
  def shape(self, value):
    self._shape = value


class Instruction:
  r"""
  Instruction instance is a single case of iterating properties of Hierarcy.
  Properties are converted to fit Hierarcy.
  """

  def __init__(self):
    self.build = ""
    self.mipmap = ""
    self.icon_name = ""

  def __str__(self):
    return (
      f"Instruction("
      f"build={self.build}, "
      f"mipmap={self.mipmap}, "
      f"icon_name={self.icon_name}"
      f")"
    )

  def get(self):
    return self.__dict__.copy()

  def update(self, **kwargs):
    for k, v in kwargs.items():
      converted = Iterator.convert(k, v)
      if 2 == len(converted):
        self.__setattr__(*converted)
    r"""
    keys and values in kwargs is Iterator style, (build, size, shape).
    Convert them into Hierarcy style, (build, mipmap, icon_name).
    """


r"""
collector helps gathering items from deeply nested structure
"""

class Collector:
  pass
  r"""
  iterable list with customized push, delete, get
  base class of Collector family
  """

  def __init__(self, collection=[]):
    self._index = -1
    self._collection = list(collection)
    r"""
    copied. also tuple is converted.
    """

  def __str__(self):
    return(
      f"{self.__class__.__name__}("
      f"{len(self._collection)} items"
      f")"
    )

  def __iter__(self):
    self._index = -1
    return self

  def __next__(self):
    self._index += 1
    if self._index < len(self._collection):
      return self._collection[self._index]
    else:
      raise StopIteration

  def push(self, value):
    self._collection.append(value)

  def delete(self):
    self._collection = []

  def get(self):
    return self._collection.copy()


class TreeCollector(Collector):
  r"""
  for collecting in a single instance
  """


class LeafCollector(Collector):
  r"""
  for collecting in multiple instances

  In binary tree search,
  parent's collector is to be independent from child's collector,
  while children's have their parent's one delivered.
  This collector can be created new instance at every movement.
  """

  def new(self):
    return self.__class__(self._collection)
    r"""
    returns a new instance with all properties copied
    """

  def add_new(self, value):
    spawned = self.new()
    spawned.push(value)
    return spawned
    r"""
    returns a new instance with value appended
    """


r"""
explorer into the deep dangeon

the dangeon has nested iterations as;
    [room#0, room#1] floor#0
    [room#0]         floor#1

add leaf mark at the end of each floor.
empty_room = [None]

  [room#0, room#1, empty_room] floor#0
  [room#0, empty_room]         floor#1

instead of counting position, detecting the None value to find a leaf.

on each floor, items across rooms are mixed to make all combinations.

  [[i0, i1], [M2, M3, M4]] will be converted to the next
  [[i0 M2], [i0, M3], [i0, M4], [i1 M2], [i1, M3], [i1, M4]]

also, floors are combined.
"""

class RoomMixer(Collector):
  r"""
  gather items across rooms on each floor
  """

  def __init__(self, floor):
    super(self.__class__, self).__init__()
    self._floor = self.append_end_marker(floor)
    self._tree = TreeCollector()
    r"""
    [None] is appended at the last of rooms to detect the end
    """

  def append_end_marker(self, floor):
    marked = list(floor)
    marked.append([None])
    return marked

  def is_end(self, item):
    return None == item

  def tree_search(self, collector, room_number = 0):
    room = self._floor[room_number]
    for item in room:
      if self.is_end(item):
        self.leaf_found(collector)
      else:
        self.next_room(collector.add_new(item), room_number)

  def leaf_found(self, collector):
    self._tree.push(self.merge_dicts(collector.get()))

  def next_room(self, collector, room_number):
    self.tree_search(collector, 1 + room_number)

  def dive(self):
    self.tree_search(LeafCollector())
    return tuple(self._tree.get())

  def merge_dicts(self, list):
    merged = dict()
    for item in list:
      for k, v in item.items():
        merged[k] = v
    return merged


class FloorMixer(Collector):
  r"""
  gather rooms across floors
  """

  def __init__(self, hierarcy, dangeon):
    super(self.__class__, self).__init__()
    self._hierarcy = hierarcy
    self._dangeon = list(dangeon)

  def is_end(self, floor_number):
    return floor_number >= len(self._dangeon)

  def tree_search(self, collector, floor_number = 0):
    if self.is_end(floor_number):
      r"""
      insert the hierarcy here
      """
      return self.hierarcy(collector.get())
    else:
      floor = self._dangeon[floor_number]
      return list(map(
        lambda item:
        self.next_floor(collector, item, floor_number)
        , self.into_rooms(floor)
      ))

  def next_floor(self, collector, item, floor_number):
    new_collector = collector.new()
    new_collector.push(item)
    return tuple(
      [
        item,
        self.tree_search(new_collector, 1 + floor_number)
      ]
    )

  def dive(self):
    return self.tree_search(LeafCollector())

  def into_rooms(self, floor):
    if floor == [None]:
      return floor
    else:
      r"""
      dive deeper
      """
      rooms = RoomMixer(floor)
      return rooms.dive()

  def hierarcy(self, conditions):
    return {"hierarcy": self._hierarcy.update(*conditions).get()}


class TreeMaker:
  pass
  r"""
  organize collections and mixers to make tree
  this will be called first

  handle nested iteration

  On GIMP,
    outer iteration is used to prepare image.
    inner iteration is used to change size and save icon file.
  """

  _dangeon = [
    ["build", "shape"],
    ["size"]
  ]

  r"""
  it defines the nested iteration
    dangeon =
    [room#0, room#1] floor#0
    [room#0]         floor#1
  """

  def __init__(self, hierarcy=Hierarchy(), adventure_map=Iterator(), dangeon=_dangeon):
    self._hierarcy = hierarcy
    self._adventure_map = adventure_map
    self._dangeon = dangeon.copy()
    self._dangeon_map = self.dangeon_map()
    self._tree = None
    r"""
    use list for iterations, not tuple
    """

  def dive(self):
    floors = FloorMixer(self._hierarcy, self._dangeon_map)
    self._tree = floors.dive()
    return self._tree

  def dangeon_map(self):
    r"""
    expand the abstract dangeon map to be real one, by the map of iterator
    """
    return list(map(lambda x: list(map(self._adventure_map.dict_for, x)), self._dangeon))


r"""
main executor
"""

class Executor:
  r"""
  called from main with command line arguments
  handles whole processes
  """

  def __init__(self, args):
    self._args = args
    self.parse_args(args)
    self._iterator_args = {k:self.__getattribute__(k) for k in Iterator.key_list if k in self._keys}

  def parse_args(self, args):
    r"""
    conert argparse argument into properties of this instance
    """
    self._keys = args.keys()
    for k, v in args.items():
      self.__setattr__(k, self.parse_arg_string(v))

  def parse_arg_string(self, obj):
    r"""
    handles list parameters
    1,2,3 -> (1,2,3)
    a,b,c -> ("a","b","c")
    """

    if isinstance(obj, str):
      quote = '"' if re.search("[^,0-9]", obj) else ""
      splitted = re.split(",", obj)
      list_str = f"({quote}" + f"{quote},{quote}".join(splitted) + f"{quote})"
      return eval(list_str)
    else:
      r"""
      expects `None`
      """
      return obj

  r"""
  the tree structure is something tricky,
    [ # list as nodes
      ( # tuple as a node
        {} # item#0 is dict as attributes
        [] # item#1 is list as child nodes
      )
    ]
  """

  def is_horizontal_list(self, obj):
    return isinstance(obj, list)

  def is_vertical_list(self, obj):
    return isinstance(obj, tuple)

  def is_hierarcy(self, obj):
    return isinstance(obj, dict)

  def node_attribute(self, node):
    return node[0]

  def node_body(self, node):
    return node[1]

  def linux_like(self, segments):
    r"""
    root directory start with / ?
    """
    return segments[0].startswith("/")

  def dir_separator(self, segments):
    return "/" if self.linux_like(segments) else "\\"

  def build_path_without_file_name(self, segments):
    return self.dir_separator(segments).join(segments[0:-1])

  def extract_directory(self, collector, node):
    r"""
    traverse tree to find out directory information
    """

    if self.is_horizontal_list(node):
      for item in node:
        self.extract_directory(collector, item)
    elif self.is_vertical_list(node):
      self.extract_directory(collector, self.node_body(node))
    elif self.is_hierarcy(node):
      hierarcy = node["hierarcy"]
      directories = hierarcy["directories"]
      segments = list(hierarcy[k] for k in directories)
      collector.push(self.build_path_without_file_name(segments))
    else:
      print(f"Node not expected here: {node}", file=sys.stderr)
      collector.push(f"NOT EXPECTED {node}")

  def to_scheme(self, collector, node, tab, base_margin):
    r"""
    traverse tree to transform the structure into scheme list

    the tree structure will be,
    ( ; list as nodes
      ( ; cons as a node
        ( ; item#0 is list as attributes
          ( key . value ) ; cons an attribute
        )
      .
        () ; item#1 is list as child nodes
      )
    )
    """

    margin = tab * base_margin
    if self.is_horizontal_list(node):
      collector.push(margin + "(")
      for item in node:
        self.to_scheme(collector, item, tab, 1 + base_margin)
      collector.push(margin + ")")
    elif self.is_vertical_list(node):
      collector.push(margin + "(")
      self.dict_to_scheme(collector, tab, 1 + base_margin, self.node_attribute(node))
      collector.push(margin + ".")
      self.to_scheme(collector, self.node_body(node), tab, 1 + base_margin)
      collector.push(margin + ")")
    elif self.is_hierarcy(node):
      hierarcy = node["hierarcy"]
      directories = hierarcy["directories"]
      segments = list(hierarcy[k] for k in directories)
      self.expand_dir_segments(collector, tab, base_margin, segments)
    else:
      print(f"Node not expected here: {node}", file=sys.stderr)
      collector.push(f"NOT EXPECTED {node}")

  def dict_to_scheme(self, collector, tab, base_margin, dict):
    r"""
    convert dict to (list (cons) (cons) ...) in scheme
    """

    margin0 = tab * base_margin
    margin1 = margin0 + tab
    margin2 = margin1 + tab
    collector.push(margin0 + "(")
    for k, v in dict.items():
      quote = '' if "size" == k else '"'
      collector.push(margin1 + "(")
      collector.push(margin2 + f'"{k}"')
      collector.push(margin1 + ".")
      collector.push(margin2 + f'{quote}{v}{quote}')
      collector.push(margin1 + ")")
    collector.push(margin0 + ")")

  def expand_dir_segments(self, collector, tab, base_margin, segments):
    r"""
    convert segment list to (list) in scheme
    """

    margin0 = tab * base_margin
    margin1 = margin0 + tab
    collector.push(margin0 + "(")
    for d in segments:
      collector.push(margin1 + f'"{d}"')
    collector.push(margin0 + ")")

  def make_tree(self):
    r"""
    build the tree structure
    """

    iterator = Iterator(**(self._iterator_args))
    self._tree_maker = TreeMaker(Hierarchy(**self._args), iterator)
    return self._tree_maker.dive()

  def make_sh(self):
    r"""
    make bash script from the tree
    """

    collector = TreeCollector()
    self.extract_directory(collector, self._tree)
    directories = collector.get()
    unique = list(set(directories))
    mkdir = "\n".join(
      (f"mkdir -p {d}" for d in unique)
    )

    return ("#!/bin/sh"
      f"""
# create directories

{mkdir}

      """
    )

  def make_scheme(self):
    r"""
    make scheme list from the tree
    """

    tab = " " * 2
    base_margin = 3 # number of tabs, not spaces
    collector = TreeCollector()
    self.to_scheme(collector, self._tree, tab, base_margin)
    icon_list = collector.get()
    icon_list_string = "\n".join(icon_list)

    return ("#!/usr/bin/env tinyscheme"
      f"""
; icon list

(let

  (
    (icon-list
      '
{icon_list_string}
    )
  )

  icon-list
)

      """
    )

  def wrap_in_bash(self, string):
    r"""
    include the scheme list in the bash script
    """

    return ("cat <<'EOS' > /dev/null"
      f"""

{string}

EOS
      """
    )

  def report(self):
    r"""
    print the result to stdout
    """
    print(self._sh)
    print(self.wrap_in_bash(self._scheme))

  def verbose(self, file=sys.stdout):
    r"""
    print verbose information
    """
    print(self._args)
    print(self._keys)
    print({k: self.__getattribute__(k) for k in self._keys})
    print(self._iterator_args)
    print(self._tree)

  def run(self):
    r"""
    handle entire processes
    """
    print('Begin.', file=sys.stderr)

    self._tree = self.make_tree()
    self._sh = self.make_sh()
    self._scheme = self.make_scheme()
    self.report()

    #self.verbose(sys.stderr)
    print('Done!', file=sys.stderr)


r"""
main to be executed
"""

def main():
  parser = argparse.ArgumentParser(prog=Document.prog, description=Document.description, epilog=Document.epilog)
  for k,d,e in Document.arguments:
    parser.add_argument(k, help=f"{d} ({e})")
  args = parser.parse_args()

  project = Executor(args.__dict__)
  project.run()


r"""
test
"""

class Test:

  r"""
  test cases, or hint for debugging...
  """

  def show_document(self):
    r"""
    show all documents
    """
    self.show_overview_with_mermaid_html()
    self.show_origin()

  def show_usage(self):
    r"""
    show usage
    """
    print(Document.usage)

  def show_origin(self):
    r"""
    show the 1st jotting
    """
    print(Document.origin)

  def show_overview(self):
    r"""
    show the 1st jotting
    """
    print(Document.overview)

  def show_overview_with_mermaid_html(self):
    r"""
    include html to call mermaid
    """
    params = "{ startOnLoad: true }"
    print(
      f"""
<html>
  <body>
    <h1>overview</h1>
    <pre class="mermaid">

{Document.overview}

    </pre>

    <script type="module">
      import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
      mermaid.initialize({params});
    </script>
  </body>
</html>
      """
    )

  def test_hierarcy_default(self):
    r"""
    test HierarcyDefault
    """

    print(HierarchyDefault)
    print(HierarchyDefault.directories)
    print(HierarchyDefault.__getattribute__(HierarchyDefault, "icon_name"))
    print(HierarchyDefault.__dict__)
    a = HierarchyDefault()
    print(a.directories)
    print(a.__getattribute__("icon_name"))
    print(a.__dict__)
    print(HierarchyDefault.__dict__.items())
    print(HierarchyDefault.__dict__.keys())
    keys = [k for k in HierarchyDefault.__dict__.keys() if not k.startswith("_")]
    print(keys)
    subset = {k: HierarchyDefault.__dict__[k] for k in keys}
    print(subset)
    print(type(subset))

  def test_hierarcy(self):
    r"""
    test Hierarcy
    """

    print(Hierarchy)
    print(Hierarchy())
    print(Hierarchy(project="my_special_project", version="lost"))
    print(Hierarchy(age="over 1000", project="my_special_project", version="lost"))
    print(Hierarchy(directories=("user_home", "icon_name")))

    a = Hierarchy(_bag="can NOT destroy the _bag")
    print(a)
    print(a._bag)
    print(a.build)
    a._bag="CAN destroy the _bag"
    print(a._bag)
    try:
      print(a.build)
    except AttributeError as e:
      print(e)

  def test_iterator(self):
    r"""
    test Iterator
    """

    print(Iterator.to_iterable(1))
    print(Iterator.to_iterable((1)))
    print(Iterator.to_iterable((1, 2)))
    print(Iterator.to_iterable([1]))
    print(Iterator.to_iterable({"a":1}))
    print(Iterator.to_iterable("string is iterable!"))

    print(Iterator())
    print(Iterator(size=(48, 144)))
    print(Iterator(shape=("round"), size=96))

    kwargs = {"size": (48, 72)}
    print(Iterator(**kwargs))
    kwargs["build"] = "debug"
    print(Iterator(**kwargs))
    kwargs["build"] = None
    print(Iterator(**kwargs))
    kwargs["hoge"] = "foo"
    print(Iterator.clean_kwargs(kwargs))
    print(Iterator(**(Iterator.clean_kwargs(kwargs))))

  def test_collector(self):
    r"""
    test Collector
    """

    print(Collector)
    a = Collector()
    print(list(x for x in a))
    a = Collector((1, 2, 3))
    a.push(4)
    print(list(x for x in a))
    print(list(x for x in a))
    print(a.get())
    a.delete()
    print(a.get())

    print(LeafCollector)
    a = LeafCollector([1, 2, 3, 4])
    b = a.add_new(5)
    print(b.get())
    print(a.get())
    print(a is b)
    print(b)

  def test_floor_mixer(self):

    print(FloorMixer)
    a = FloorMixer(Hierarchy(), [[({"a":3},{"b":4}),({"c":5},{"d":6})],[({"x":7},{"y":8})]])
    print(a)
    print(a._collection)
    print(a._dangeon)
    print(a.dive())

    print(TreeMaker)
    print(TreeMaker().dive())

  def test_executor(self):
    r"""
    test executor
    """
    print(Executor)
    #a = Executor()
    a = Executor({"project": "a", "version": "b", "size": "96,144"})
    #print(a._hierarchy)
    print(a._keys)
    print(a.__dict__)
    print(a.__getattribute__("size"))
    a.run()
    print(a._tree)

  def test_misc(self):
    r"""
    test miscellaneous
    """
    pass

    #Hoge()
    #Hoge(1, 2, 3)


r"""
runner
"""

if __name__ == '__main__':

  #Test().show_document()
  #Test().show_usage()
  #Test().show_origin()
  #Test().show_overview()
  #Test().show_overview_with_mermaid_html()

  #Test().test_hierarcy_default()
  #Test().test_hierarcy()
  #Test().test_iterator()
  #Test().test_collector()
  #Test().test_floor_mixer()
  #Test().test_executor()

  #Test().test_misc()

  main()

