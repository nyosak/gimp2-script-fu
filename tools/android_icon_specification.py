#!/usr/bin/env python3

r"""
generates a case list for android icon creator
copyright 2025, hanagai

android_icon_specification.py
version: March 29, 2025

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
    ("--config", "configuration class", "ConfigDefault"),
    ("--project", "project name in Hierarchy", "MyProject"),
    ("--version", "version name in Hierarchy", "MyVersion"),
    ("--user_home", "user home directory in Hierarchy", "/home/kuro"),
    ("--studio_home", "studio home directory in Hierarchy", "AndroidStudioProjects"),
    ("--src", "source directory in Hierarchy", "app/src"),
    ("--res", "resource directory in Hierarchy", "res"),
    ("--mipmap", "mipmap directory in Hierarchy", "mipmap-mdpi"),
    ("--icon_name", "icon file name in Hierarchy", "ic_launcher.webp"),
    ("--build", "build type in Iterator", "main,debug,release"),
    ("--shape", "icon shape in Iterator", "square,round"),
    ("--size", "icon size in Iterator", "48,72,96,144,192"),
    ("--dangeon", "dangeon map in Dangeon", "[['build', 'shape'], ['size']]"),
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

  Dangeon

  ConfigBase --> ConfigDefault
  ConfigBase --> ConfigTest
  ConfigBase --> Config1

  Hierarchy -- customised --> config
  Iterator -- customised --> config
  Dangeon -- customised --> config

  TreeExplorer --> FileExplorer
  FileExplorer --> MkdirExplorer --> bash1
  FileExplorer --> GitAddExplorer --> bash2
  TreeExplorer --> SchemeExplorer --> scheme

  Document -- define args --> ConfigBase

  HierarchyDefault -- initialize --> Hierarchy
  Instruction -- update --> Hierarchy
  Iterator -- iterate --> Instruction

  Collector -- subclass --> TreeCollector
  Collector -- subclass --> LeafCollector

  config -- Hierarchy  --> TreeMaker
  config -- Iterator  --> TreeMaker
  config -- Dangeon --> TreeMaker
  TreeMaker -- deeper --> FloorMixer -- deeper --> RoomMixer

  FloorMixer -- gather ----> LeafCollector
  FloorMixer -- gather ----> TreeCollector
  RoomMixer -- gather ----> LeafCollector
  RoomMixer -- gather ----> TreeCollector

  TreeCollector -- tree --> TreeMaker
  LeafCollector -- leaf --> FloorMixer
  LeafCollector -- leaf --> RoomMixer

  main("main()") -- run ------> Executor
  Executor -- run --> TreeMaker

  main -- args ---> ConfigDefault -- config ---> Executor

  TreeMaker -- create --> the_tree
  the_tree -- transform --> explorer

  Executor --- the_tree[(the tree)]
  Executor --- bash1[(bash mkdir)]
  Executor --- bash2[(bash gid add)]
  Executor --- scheme[(scheme list)]

  command([command line]) ----> main
  bash1 -- stdout --> output([output result])
  bash2 -- stdout --> output([output result])
  scheme -- stdout --> output
  customize([customize]) ------> config

  Test

subgraph documents
  Document
end

subgraph hierarchies
  HierarchyDefault
  Hierarchy
  Iterator
  Instruction
  Dangeon
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

subgraph explorer
  TreeExplorer
  FileExplorer
  MkdirExplorer
  GitAddExplorer
  SchemeExplorer
end

subgraph runner
  Executor
  main
  the_tree
  bash1
  bash2
  scheme
end

subgraph config
  ConfigBase
  ConfigDefault
  ConfigTest
  Config1
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

  key_list = (
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
    accept only keys defined in HierarchyDefault
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
    initialize property _bag with HierarchyDefault
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

  This class have iterating properties of Hierarchy.
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
    convert Iterator style key-value into Hierarchy style.
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
  Instruction instance is a single case of iterating properties of Hierarchy.
  Properties are converted to fit Hierarchy.
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
    Convert them into Hierarchy style, (build, mipmap, icon_name).
    """


r"""
collector helps gathering items from deeply nested structure
"""

class Collector:
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

  def pop(self):
    return self._collection.pop()

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

  def __init__(self, hierarchy, dangeon):
    super(self.__class__, self).__init__()
    self._hierarchy = hierarchy
    self._dangeon = list(dangeon)

  def is_end(self, floor_number):
    return floor_number >= len(self._dangeon)

  def tree_search(self, collector, floor_number = 0):
    if self.is_end(floor_number):
      r"""
      insert the hierarchy here
      """
      return self.hierarchy(collector.get())
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

  def hierarchy(self, conditions):
    return {TreeExplorer.MARK_AS_HIERARCHY: self._hierarchy.update(*conditions).get()}


class Dangeon:
  r"""
  map used at TreeMaker
  """

  key_list = ("dangeon")

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

  def __init__(self, dangeon=_dangeon):
    self._dangeon = dangeon

  def __str__(self):
    return (
      f"{self.__class__.__name__}("
      f"{self.dangeon}, "
      f")"
    )

  def dangeon_map(self, iterator):
    r"""
    expand the abstract dangeon map to be real one, by the map of iterator
    """
    return list(map(lambda x: list(map(iterator.dict_for, x)), self._dangeon))

  @property
  def dangeon(self):
    return self._dangeon


class TreeMaker:
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

  def __init__(self, hierarchy=Hierarchy(), adventure_map=Iterator(), dangeon=Dangeon()):
    self._hierarchy = hierarchy
    self._adventure_map = adventure_map
    self._dangeon = dangeon
    self._dangeon_map = dangeon.dangeon_map(adventure_map)
    self._tree = None
    r"""
    use list for iterations, not tuple
    """

  def dive(self):
    floors = FloorMixer(self._hierarchy, self._dangeon_map)
    self._tree = floors.dive()
    return self._tree


r"""
tree explorer
"""

class TreeExplorer:
  r"""
  base class to explore the tree
  """

  MARK_AS_HIERARCHY = "Marked as Hierarchy"

  def begin(self, node, opts):
    return self.apply_node(node, opts)

  def apply_node(self, node, opts):
    match self.node_type(node):
      case "L":
        return self.func_l(node, opts)
      case "N":
        return self.func_n(node, opts)
      case "A":
        return self.func_a(node, opts)
      case "H":
        return self.func_h(node, opts)
      case _:
        return self.func_else(node, opts)

  def func_l(self, node, opts):
    return [self.apply_node(item, opts) for item in node]

  def func_n(self, node, opts):
    return (
      self.apply_node(self.node_attribute(node), opts),
      self.apply_node(self.node_body(node), opts)
    )

  def func_a(self, node, opts):
    return node

  def func_h(self, node, opts):
    return self.get_hierarchy_contents(node)

  def func_else(self, node, opts):
    return "NOT EXPECTED"

  def node_type(self, node):
    if isinstance(node, list):
      return "L"  # nodes
    elif isinstance(node, tuple):
      return "N"  # node
    elif isinstance(node, dict):
      if self.is_marked_as_hierarchy(node):
        return "H"  # hierarchy
      else:
        return "A"  # attributes
    else:
      return None

  r"""
  the tree structure is something tricky,
    [ # list as nodes
      ( # tuple as a node
        {} # item#0 is dict as attributes
        [] # item#1 is list as child nodes
      )
    ]
  """

  def node_attribute(self, node):
    return node[0]

  def node_body(self, node):
    return node[1]

  def get_hierarchy_contents(self, node):
    return node.get(self.MARK_AS_HIERARCHY)

  def is_marked_as_hierarchy(self, node):
    return None != self.get_hierarchy_contents(node)



class FileExplorer(TreeExplorer):
  r"""
  explores the tree to find out file path
  """

  def begin(self, node, opts):
    if None == opts.get("collector"):
      opts["collector"] = TreeCollector()
    node_result = self.apply_node(node, opts)
    return opts["collector"].get()

  def func_h(self, node, opts):
    hierarchy = self.get_hierarchy_contents(node)
    directories = hierarchy.get("key_list")
    segments = list(hierarchy[k] for k in directories)
    opts["collector"].push(segments)

  def func_else(self, node, opts):
    opts["collector"].push("NOT EXPECTED")

  def linux_like(self, segments):
    r"""
    root directory start with / ?
    """
    return segments[0].startswith("/")

  def dir_separator(self, segments):
    return "/" if self.linux_like(segments) else "\\"

  def build_path_without_file_name(self, segments):
    return self.dir_separator(segments).join(segments[0:-1])

  def build_path_with_file_name(self, segments):
    return self.dir_separator(segments).join(segments)


class MkdirExplorer(FileExplorer):
  r"""
  explores the tree to make bash mkdir command
  """

  def func_h(self, node, opts):
    super(self.__class__, self).func_h(node, opts)
    segments = opts["collector"].pop()
    path = self.build_path_without_file_name(segments)
    #command = f"mkdir -p {path}"
    opts["collector"].push(path)


class GitAddExplorer(FileExplorer):
  r"""
  explores the tree to make bash git add command
  """

  def func_h(self, node, opts):
    super(self.__class__, self).func_h(node, opts)
    segments = opts["collector"].pop()
    path = self.build_path_with_file_name(segments)
    #command = f"git add {path}"
    opts["collector"].push(path)


class SchemeExplorer(TreeExplorer):
  r"""
  expores the tree to make scheme list for GIMP script-fu
  """

  def __init__(self, base_margin=4, tab=" "*2):
    self.tab = tab
    self.base_margin = base_margin

  def begin(self, node, opts):
    if None == opts.get("collector"):
      opts["collector"] = TreeCollector()
    if None == opts.get("margin"):
      opts["margin"] = self.base_margin
    if None == opts.get("tab"):
      opts["tab"] = self.tab
    node_result = self.apply_node(node, opts)
    return opts["collector"].get()

  def func_l(self, node, opts):
    margin = opts["tab"] * opts["margin"]
    opts["collector"].push(margin + "( #\\L")
    for item in node:
      self.apply_node(item, self.margin_plus(opts))
    opts["collector"].push(margin + ")")

  def func_n(self, node, opts):
    margin = opts["tab"] * opts["margin"]
    opts["collector"].push(margin + "( #\\N")
    self.apply_node(self.node_attribute(node), self.margin_plus(opts)),
    self.apply_node(self.node_body(node), self.margin_plus(opts))
    opts["collector"].push(margin + ")")

  def func_a(self, node, opts):
    margin0 = opts["tab"] * opts["margin"]
    margin1 = margin0 + opts["tab"]
    margin2 = margin1 + opts["tab"]
    opts["collector"].push(margin0 + "( #\\A")
    for k, v in node.items():
      quote = '' if "size" == k else '"'
      opts["collector"].push(margin1 + "(")
      opts["collector"].push(margin2 + f'"{k}"')
      opts["collector"].push(margin1 + ".")
      opts["collector"].push(margin2 + f'{quote}{v}{quote}')
      opts["collector"].push(margin1 + ")")
    opts["collector"].push(margin0 + ")")

  def func_h(self, node, opts):
    hierarchy = self.get_hierarchy_contents(node)
    directories = hierarchy.get("key_list")
    segments = list(hierarchy[k] for k in directories)
    self.expand_dir_segments(segments, opts)

  def func_else(self, node, opts):
    opts["collector"].push("NOT EXPECTED")

  def expand_dir_segments(self, segments, opts):
    r"""
    convert segment list to (list) in scheme
    """

    margin0 = opts["tab"] * opts["margin"]
    margin1 = margin0 + opts["tab"]
    opts["collector"].push(margin0 + "( #\\H")
    for d in segments:
      opts["collector"].push(margin1 + f'"{d}"')
    opts["collector"].push(margin0 + ")")

  def margin_plus(self, opts):
    new_opts = {}
    for k in opts.keys():
      new_opts[k] = 1 + opts[k] if "margin" == k else opts[k]
    return new_opts


r"""
main executor
"""

class Executor:
  r"""
  called from main with command line arguments
  handles whole processes
  """

  def __init__(self, config):
    self._config = config
    #self._args = args    #self.parse_args(args)
    #self._iterator_args = {k:self.__getattribute__(k) for k in Iterator.key_list if k in self._keys}

  def make_tree(self):
    r"""
    build the tree structure
    """

    self._tree_maker = TreeMaker(
      self._config.hierarchy(),
      self._config.iterator(),
      self._config.dangeon()
    )
    return self._tree_maker.dive()

  def make_mkdir_sh(self):
    r"""
    make bash script from the tree
    """

    explorer = MkdirExplorer()
    directories = explorer.begin(self._tree, {})
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

  def make_git_add_sh(self):
    r"""
    make bash script from the tree
    """

    explorer = GitAddExplorer()
    files = explorer.begin(self._tree, {})
    git_add = "\n".join(
      (f"git add {d}" for d in files)
    )

    return ("#!/bin/sh"
      f"""
# git add files

{git_add}

      """
    )

  def make_scheme(self):
    r"""
    make scheme list from the tree
    """

    explorer = SchemeExplorer()
    icon_list = explorer.begin(self._tree, {})
    icon_list_string = "\n".join(icon_list)

    key_list = self._config.hierarchy().key_list
    argument_key = ("project", "version")
    argument_list = (f'"{k}"' if k in argument_key else "#f" for k in key_list)
    key_list_string = '("' + '" "'.join(key_list) + '")'
    argument_list_string = '(' + ' '.join(argument_list) + ')'

    build_list = self._config.iterator().build
    shape_list = self._config.iterator().shape
    build_list_string = '("' + '" "'.join(build_list) + '")'
    shape_list_string = '("' + '" "'.join(shape_list) + '")'

    return ("#!/usr/bin/env tinyscheme"
      f"""
; icon list

  (let

    (

      ; --- variables BEGIN ---

      (hierarchy
        '{key_list_string}
      )

      (arguments
        '{argument_list_string}
      )

      (iterator-build
        '{build_list_string}
      )

      (iterator-shape
        '{shape_list_string}
      )

      (icon-list
        '
{icon_list_string}
      )

      ; --- variables END ---

    )

    hierarchy
    arguments
    iterator-build
    iterator-shape
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
    print(self.wrap_in_bash(self._sh_git_add))
    print(self.wrap_in_bash(self._scheme))

  def verbose(self, file=sys.stdout):
    r"""
    print verbose information
    """
    #print(self._args)
    #print(self._keys)
    #print({k: self.__getattribute__(k) for k in self._keys})
    #print(self._iterator_args)
    print(self._config)
    print(self._tree)

  def run(self):
    r"""
    handle entire processes
    """
    print('Begin.', file=sys.stderr)

    self._tree = self.make_tree()
    self._sh = self.make_mkdir_sh()
    self._sh_git_add = self.make_git_add_sh()
    self._scheme = self.make_scheme()
    self.report()

    #self.verbose(sys.stderr)
    print('Done!', file=sys.stderr)



r"""
customize
"""

class ConfigBase:
  r"""
  Base of configuration classes.
  Customize a subclass of this to change deafult behavior.
  """

  arguments = Document.arguments

  @classmethod
  def class_by_name(cls, name):
    return getattr(__import__(__name__), name)

  def __init__(self, argv=sys.argv):
    self._argv = argv
    self._config = None # will be set at next line
    parse_known_config = self.parse_args_config(argv)
    self._arg_config = parse_known_config[0]  # --config only
    self._args = self.parse_args(parse_known_config[1]) # excluding --config
    self._effective_args = self.effective_args(self._args)
    r"""
    effective args are applied in following order
    """
    self._tmp_args = self._effective_args.copy()
    self._dangeon = self.dangen_args(self._tmp_args)
    self._iterator = self.iterator_args(self._tmp_args)
    self._hierarchy = self.hierarchy_args(self._tmp_args)

  def __str__(self):
    return (
      f"{self.__class__.__name__}("
      f"__dict__={self.__dict__}, "
      f")"
    )

  def parser(self):
    return argparse.ArgumentParser(prog=Document.prog, description=Document.description, epilog=Document.epilog)

  def parse_args_config(self, argv):
    parser = self.parser()
    parser.add_argument("--config", help="1st, parse only config to catch changing the world")
    args = parser.parse_known_args()
    self._config = args[0].config
    return args

  def parse_args(self, argv):
    parser = self.parser()
    #print(self.config_class)
    for k,d,e in self.config_class().arguments:
      parser.add_argument(k, help=f"{d} ({e})")
    return parser.parse_args(argv)

  def effective_args(self, args):
    r"""
    explicitly specified args at command line
    """
    return {k:v for k,v in args.__dict__.items() if None != v}

  def dangen_args(self, args):
    return self.pick_args_for_class(Dangeon, args)

  def iterator_args(self, args):
    return self.pick_args_for_class(Iterator, args)

  def hierarchy_args(self, args):
    return self.pick_args_for_class(HierarchyDefault, args)

  def class_key_list(self, klass):
    r"""
    override this if customized key_list is needed.
    """
    return klass.key_list

  def pick_args_for_class(self, klass, args):
    r"""
    expects args as temporary dictionary
    returns subset of dictionary where the key is found in class_key_list
    remvoe those keys from the temporary dictionary
    """
    key_list = self.class_key_list(klass)
    good_args = {k:self.parse_arg_string(v) for k,v in args.items() if k in key_list}
    for k in tuple(args.keys()):
      if k in key_list:
        args.pop(k)
    return good_args

  def parse_arg_string(self, obj):
    r"""
    handles list parameters
    1,2,3 -> (1,2,3)
    a,b,c -> ("a","b","c")
    ("a","b") -> as is
    """

    if isinstance(obj, str):
      if re.search("[\[(]", obj):
        r"""
        expects formatted string that can directly eval
        """
        list_str = obj
      else:
        quote = '"' if re.search("[^,0-9]", obj) else ""
        splitted = re.split(",", obj)
        list_str = f"({quote}" + f"{quote},{quote}".join(splitted) + f"{quote})"
      return eval(list_str)
    else:
      r"""
      expects `None`
      """
      return obj

  def divide_list_by_keys(self, keys, list):
    r"""
    expects dict.items() as list
    apply condition true when the key in the list is in keys.
    """
    return (self.divide_list_by(lambda x: x[0] in keys, list))

  def divide_list_by(self, condition, list):
    r"""
    divide list into two lists by condition, (bad_list, good_list)
    expects condition as a function that gives False or True.
    """
    bad_list = [x for x in list if not condition(x)]
    good_list = [x for x in list if condition(x)]
    return (bad_list, good_list)

  def merge_dicts(self, dict_base, dict_up):
    r"""
    adds or updates dict_base by dict_up and return new dict
    """
    new_dict = {}
    if not None == dict_base:
      for k,v in dict_base.items():
        new_dict[k] = v
    if not None == dict_up:
      for k,v in dict_up.items():
        new_dict[k] = v
    return new_dict

  r"""
  for Executor
  """

  def config_class(self):
    return self.__class__ if None == self._config else self.__class__.class_by_name(self._config)

  def config(self):
    r"""
    executor must use this instead of self
    """
    return self if None == self._config else self.__class__.class_by_name(self._config)(self._args)

  def hierarchy(self):
    return Hierarchy(**(self._hierarchy))

  def iterator(self):
    return Iterator(**(self._iterator))

  def dangeon(self):
    return Dangeon(**(self._dangeon))


class ConfigDefault(ConfigBase):
  r"""
  default config
  """


class ConfigTest(ConfigBase):
  r"""
  small config for test
  """

  def hierarchy(self):
    defaults = {
      "studio_home": "tmp/art_work",
      "project": "p",
      "version": "v",
    }
    merged = self.merge_dicts(defaults, self._hierarchy)
    return Hierarchy(**merged)

  def iterator(self):
    defaults = {
      "build": ["main"],
      "size": [96],
      "shape": ["square"],
    }
    merged = self.merge_dicts(defaults, self._iterator)
    return Iterator(**merged)


class Config1(ConfigBase):
  r"""
  another config for my primary use
  no release icons
  """

  def hierarchy(self):
    defaults = {
      "user_home": "/home/kuro",
    }
    merged = self.merge_dicts(defaults, self._hierarchy)
    return Hierarchy(**merged)

  def iterator(self):
    defaults = {
      "build": ["main", "debug"],
    }
    merged = self.merge_dicts(defaults, self._iterator)
    return Iterator(**merged)


r"""
main to be executed
"""

def main():
  config = Config1()
  #config = ConfigDefault()
  project = Executor(config.config())
  project.run()


r"""
test
"""

class Test:
  r"""
  test cases, or hint for debugging...
  """

  def __init__(self, *args):
    self.args = args

  def show_document(self):
    r"""
    show all documents
    """
    print(self.md_overview())
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
    show the mermaid overview
    """
    print(Document.overview)

  def md_overview(self):
    r"""
    markdown flavored mermaid overview
    """
    return (
      f"""
```mermaid
{Document.overview}
```
      """
    )

  def html_overview(self):
    r"""
    html flavored mermaid overview
    """
    params = "{ startOnLoad: true }"
    return f"""
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

  def show_overview_with_mermaid_html(self):
    r"""
    include html to call mermaid
    """
    print(self.html_overview())

  def test_hierarchy_default(self):
    r"""
    test HierarchyDefault
    """

    print(HierarchyDefault)
    print(HierarchyDefault.key_list)
    print(HierarchyDefault.__getattribute__(HierarchyDefault, "icon_name"))
    print(HierarchyDefault.__dict__)
    a = HierarchyDefault()
    print(a.key_list)
    print(a.__getattribute__("icon_name"))
    print(a.__dict__)
    print(HierarchyDefault.__dict__.items())
    print(HierarchyDefault.__dict__.keys())
    keys = [k for k in HierarchyDefault.__dict__.keys() if not k.startswith("_")]
    print(keys)
    subset = {k: HierarchyDefault.__dict__[k] for k in keys}
    print(subset)
    print(type(subset))

  def test_hierarchy(self):
    r"""
    test Hierarchy
    """

    print(Hierarchy)
    print(Hierarchy())
    print(Hierarchy(project="my_special_project", version="lost"))
    print(Hierarchy(age="over 1000", project="my_special_project", version="lost"))
    print(Hierarchy(key_list=("user_home", "icon_name")))

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

  def test_config(self):
    print(ConfigBase)

    #import os
    #print(os.path.basename(sys.argv[0]))
    print(sys.argv)

    parser = argparse.ArgumentParser(prog=Document.prog, description=Document.description, epilog=Document.epilog)
    #for k,d,e in ConfigDefault.arguments:
    #  parser.add_argument(k, help=f"{d} ({e})")
    parser.add_argument("--config")
    #parser.add_argument("--config2")
    #args = parser.parse_known_args(["--config"])
    #args = parser.parse_known_args(ConfigDefault.arguments)
    #args = parser.parse_args()
    #args = parser.parse_known_args(sys.argv)
    args = parser.parse_known_args()
    print(args)
    print(args[0].config)

    print(ConfigBase.class_by_name("ConfigDefault"))
    #print(ConfigBase.class_by_name("ConfigHoge"))
    config = ConfigDefault if None == args[0].config else ConfigBase.class_by_name(args[0].config)
    #print(getattr(__import__(__name__), "ConfigDefault")(args))
    print(config)

    parser = argparse.ArgumentParser(prog=Document.prog, description=Document.description, epilog=Document.epilog, exit_on_error=False)
    for k,d,e in config.arguments:
      parser.add_argument(k, help=f"{d} ({e})")
    args = parser.parse_args()

    a = ConfigBase()
    print(a)
    print(a.config())

    a = config()
    print(a)
    print(a.config())

    print(a.divide_list_by(lambda x: x > 5, [1,9,2,8,3,7,4,6,5]))
    print(a.divide_list_by_keys([1,2,3,5,7], [(1,"x1"), (9,"x9"), (2,"x2"), (8,"x8"), (3,"x3"), (7,"x7"), (4,"x4"), (6,"x6"), (5,"z5")]))

    print(a.hierarchy())
    print(a.iterator())
    print(a.dangeon())

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

  #Test().test_config()
  #Test().test_hierarchy_default()
  #Test().test_hierarchy()
  #Test().test_iterator()
  #Test().test_collector()
  #Test().test_floor_mixer()
  #Test().test_executor()

  #Test().test_misc()

  main()

